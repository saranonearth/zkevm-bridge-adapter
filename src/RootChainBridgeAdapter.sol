// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IERC20} from "oz/token/ERC20/IERC20.sol";
import {SafeERC20} from "oz/token/ERC20/utils/SafeERC20.sol";
import {Initializable} from "upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {AccessControlDefaultAdminRulesUpgradeable} from "upgradeable/access/AccessControlDefaultAdminRulesUpgradeable.sol";

import {IZkEVMBridgeAdapter} from "./interface/IZkEVMBridgeAdapter.sol";
import {IZkEVMBridge} from "./interface/IZkEVMBridge.sol";
import {ERC20Token} from "./util/ERC20Token.sol";

contract RootChainBridgeAdapter is
    IZkEVMBridgeAdapter,
    Initializable,
    UUPSUpgradeable,
    AccessControlDefaultAdminRulesUpgradeable
{
    using SafeERC20 for IERC20;

    IERC20 public token;

    /**
     * @dev bridge address on mainnet
     */
    IZkEVMBridge public zkEVMBridge;

    address public childChainBridgeAdapterAddress;

    uint32 public childChainNetworkID;

    event CustomERC20Bridged(
        address indexed sender,
        address indexed recipient,
        uint256 amount
    );

    event CustomERC20Claimed(address indexed recipient, uint256 amount);

    error BridgeAmountInvalid();

    error MessageInvalid();

    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _adminAddress,
        address _tokenAddress,
        address _bridgeAddress,
        uint32 _childChainNetworkID
    ) public initializer {
        __AccessControlDefaultAdminRules_init(3 days, _adminAddress);
        __UUPSUpgradeable_init();

        token = IERC20(_tokenAddress);
        zkEVMBridge = IZkEVMBridge(_bridgeAddress);
        childChainNetworkID = _childChainNetworkID;
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(DEFAULT_ADMIN_ROLE) {}

    function setBridgeAdapterAddress(
        address _addresss
    ) public virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        childChainBridgeAdapterAddress = _addresss;
    }

    function bridgeToken(
        address recipient,
        uint256 amount,
        bool forceUpdateGlobalExitRoot
    ) external payable {
        if (amount < 1 ether) revert BridgeAmountInvalid();
        token.safeTransferFrom(msg.sender, address(this), amount);
        bytes memory messageData = abi.encode(recipient, amount);
        zkEVMBridge.bridgeMessage(
            childChainNetworkID,
            childChainBridgeAdapterAddress,
            forceUpdateGlobalExitRoot,
            messageData
        );
        emit CustomERC20Bridged(msg.sender, recipient, amount);
    }

    function onMessageReceived(
        address originAddress,
        uint32 originNetwork,
        bytes memory data
    ) external payable {
        if (msg.sender != address(zkEVMBridge)) revert MessageInvalid();
        if (originAddress != childChainBridgeAdapterAddress)
            revert MessageInvalid();
        if (originNetwork != childChainNetworkID) revert MessageInvalid();

        (address recipient, uint256 amount) = abi.decode(
            data,
            (address, uint256)
        );
        token.safeTransfer(recipient, amount);

        emit CustomERC20Claimed(recipient, amount);
    }
}
