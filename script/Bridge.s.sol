// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {ChildChainBridgeAdapter} from "../src/ChildChainBridgeAdapter.sol";
import {RootChainBridgeAdapter} from "../src/RootChainBridgeAdapter.sol";
import {AddressScript} from "./address.s.sol";
import {ERC20Token} from "../src/util/ERC20Token.sol";

contract BridgeScript is Script, AddressScript {
    function setUp() public {}

    function run() public {
        uint privateKey = vm.envUint("GOERLI_PRIVATE_KEY");
        address account = vm.addr(privateKey);

        console.log(account);
        vm.startBroadcast(privateKey);
        // ERC20Token token = ERC20Token(erc20Token);
        // token.approve(address(rootAdapterProxy), 3 ether);
        // uint256 alloance = token.allowance(address(account), rootAdapterProxy);
        // console.log(alloance);
        RootChainBridgeAdapter rootAdapter = RootChainBridgeAdapter(
            rootAdapterProxy
        );
        rootAdapter.bridgeToken(
            0x385134a9c83E02ea204007d46550174C43b61332,
            1 ether,
            false
        );
        vm.stopBroadcast();
    }
}
