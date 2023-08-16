// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {ChildChainBridgeAdapter} from "../src/ChildChainBridgeAdapter.sol";
import {RootChainBridgeAdapter} from "../src/RootChainBridgeAdapter.sol";
import {UUPSProxy} from "./UUPSProxy.sol";

contract ChildAdapterDeploymentScript is Script {
    function setUp() public {}

    address public erc20Token = 0x20e8337597474636F95B68594EcB8DADeC4d3604;
    address public admin = 0x385134a9c83E02ea204007d46550174C43b61332;
    address public root_adapter = 0x5eB6485573C2Ea289554A044e1D34b41958c0842;
    address public zkevm_bridge = 0xF6BEEeBB578e214CA9E23B0e9683454Ff88Ed2A7;

    function run() public {
        uint privateKey = vm.envUint("ZKEVM_PRIVATE_KEY");
        address account = vm.addr(privateKey);

        console.log(account);

        vm.startBroadcast(privateKey);
        ChildChainBridgeAdapter adapter = new ChildChainBridgeAdapter();
        bytes memory data = abi.encodeWithSelector(
            ChildChainBridgeAdapter.initialize.selector,
            admin,
            erc20Token,
            zkevm_bridge,
            root_adapter,
            0
        );
        UUPSProxy proxy = new UUPSProxy(address(adapter), data);
        console.log("Logic Address", address(adapter));
        console.log("Proxy Address", address(proxy));
        vm.stopBroadcast();
    }
}

contract UpdateChildAdapterInRootScript is Script {
    function setUp() public {}

    address public childAdapeter = 0x6b0393fD45B1a95EfB1bcd93536DaB44417119C3;
    address public rootAdapter = 0x5eB6485573C2Ea289554A044e1D34b41958c0842;

    function run() public {
        uint privateKey = vm.envUint("GOERLI_PRIVATE_KEY");
        address account = vm.addr(privateKey);

        console.log(account);

        vm.startBroadcast(privateKey);
        RootChainBridgeAdapter adapter = RootChainBridgeAdapter(rootAdapter);
        adapter.setBridgeAdapterAddress(childAdapeter);
        vm.stopBroadcast();
    }
}
