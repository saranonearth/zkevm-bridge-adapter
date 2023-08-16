// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {WrappedERC20Token} from "../src/util/WrappedERC20Token.sol";

contract WrappedTokenDeploymentScript is Script {
    function setUp() public {}

    address public zkevm_bridge_adapter =
        0xF6BEEeBB578e214CA9E23B0e9683454Ff88Ed2A7;

    function run() public {
        uint privateKey = vm.envUint("ZKEVM_PRIVATE_KEY");
        address account = vm.addr(privateKey);

        console.log(account);

        vm.startBroadcast(privateKey);
        WrappedERC20Token token = new WrappedERC20Token(
            "Wrapped Sample USDC",
            "wsUSDC"
        );
        console.log("Wrapped Token Address", address(token));
        vm.stopBroadcast();
    }
}

contract UpdateOwnershipScript is Script {
    function setUp() public {}

    address wrapped_token = 0x20e8337597474636F95B68594EcB8DADeC4d3604;
    address child_adapter = 0x6b0393fD45B1a95EfB1bcd93536DaB44417119C3;

    function run() public {
        uint privateKey = vm.envUint("ZKEVM_PRIVATE_KEY");
        address account = vm.addr(privateKey);

        console.log(account);

        vm.startBroadcast(privateKey);
        WrappedERC20Token token = WrappedERC20Token(wrapped_token);
        token.changeOwner(child_adapter);
        vm.stopBroadcast();
    }
}
