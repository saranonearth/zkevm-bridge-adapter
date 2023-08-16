// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IZkEVMBridgeAdapter {
    function bridgeToken(
        address recipient,
        uint256 amount,
        bool forceUpdateGlobalExitRoot
    ) external payable;

    function onMessageReceived(
        address originAddress,
        uint32 originNetwork,
        bytes memory data
    ) external payable;
}
