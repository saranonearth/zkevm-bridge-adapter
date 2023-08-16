// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Initializable} from "upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {AccessControlDefaultAdminRulesUpgradeable} from "upgradeable/access/AccessControlDefaultAdminRulesUpgradeable.sol";
import {Ownable2StepUpgradeable} from "upgradeable/access/Ownable2StepUpgradeable.sol";
import {ERC20Upgradeable} from "upgradeable/token/ERC20/ERC20Upgradeable.sol";

import {IZkEVMBridgeAdapter} from "./interface/IZkEVMBridgeAdapter.sol";
import {IZkEVMBridge} from "./interface/IZkEVMBridge.sol";
import {WrappedERC20Token} from "./util/WrappedERC20Token.sol";

contract ChildChainBridgeAdapter is
    IZkEVMBridgeAdapter,
    Initializable,
    UUPSUpgradeable,
    Ownable2StepUpgradeable
{
    WrappedERC20Token public token;

    /**
     * @dev bridge address on polygon zkevm
     */
    IZkEVMBridge public zkEVMBridge;

    address public rootChainBridgeAdapterAddress;

    uint32 public rootChainNetworkID;

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
        address _rootChainBridgeAdapterAddress,
        uint32 _rootChainNetworkID
    ) public initializer {
        __Ownable2Step_init();
        __UUPSUpgradeable_init();

        _transferOwnership(_adminAddress);

        rootChainBridgeAdapterAddress = _rootChainBridgeAdapterAddress;
        token = WrappedERC20Token(_tokenAddress);
        zkEVMBridge = IZkEVMBridge(_bridgeAddress);
        rootChainNetworkID = _rootChainNetworkID;
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}

    function setBridgeAdapterAddress(
        address _addresss
    ) public virtual onlyOwner {
        rootChainBridgeAdapterAddress = _addresss;
    }

    function bridgeToken(
        address recipient,
        uint256 amount,
        bool forceUpdateGlobalExitRoot
    ) external payable {
        if (amount < 1 ether) revert BridgeAmountInvalid();
        token.burn(msg.sender, amount);
        bytes memory messageData = abi.encode(recipient, amount);
        zkEVMBridge.bridgeMessage(
            rootChainNetworkID,
            rootChainBridgeAdapterAddress,
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
        if (originAddress != rootChainBridgeAdapterAddress)
            revert MessageInvalid();
        if (originNetwork != rootChainNetworkID) revert MessageInvalid();

        (address recipient, uint256 amount) = abi.decode(
            data,
            (address, uint256)
        );
        token.mint(recipient, amount);

        emit CustomERC20Claimed(recipient, amount);
    }
}
