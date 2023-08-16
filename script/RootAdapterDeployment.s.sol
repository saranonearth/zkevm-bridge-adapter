// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {RootChainBridgeAdapter} from "../src/RootChainBridgeAdapter.sol";
import {UUPSProxy} from "./UUPSProxy.sol";

contract RootAdapterDeploymentScript is Script {
    function setUp() public {}

    address public erc20Token = 0xCDB5456dCDFE09e7CB78BE79C8e4bF3C7498e217;
    address public admin = 0x385134a9c83E02ea204007d46550174C43b61332;
    address public goerli_bridge = 0xF6BEEeBB578e214CA9E23B0e9683454Ff88Ed2A7;

    function run() public {
        uint privateKey = vm.envUint("GOERLI_PRIVATE_KEY");
        address account = vm.addr(privateKey);

        console.log(account);

        vm.startBroadcast(privateKey);
        RootChainBridgeAdapter adapter = new RootChainBridgeAdapter();
        bytes memory data = abi.encodeWithSelector(
            RootChainBridgeAdapter.initialize.selector,
            admin,
            erc20Token,
            goerli_bridge,
            1
        );
        UUPSProxy proxy = new UUPSProxy(address(adapter), data);
        console.log("Logic Address", address(adapter));
        console.log("Proxy Address", address(proxy));
        vm.stopBroadcast();
    }
}
