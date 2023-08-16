// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {ERC20Token} from "../src/util/ERC20Token.sol";

contract TokenDeploymentScript is Script {
    function setUp() public {}

    address public erc20Token = 0xCDB5456dCDFE09e7CB78BE79C8e4bF3C7498e217;

    function run() public {
        uint privateKey = vm.envUint("GOERLI_PRIVATE_KEY");
        address account = vm.addr(privateKey);

        console.log(account);

        vm.startBroadcast(privateKey);
        ERC20Token token = ERC20Token(erc20Token);
        token.mint(account, 10 ether);
        vm.stopBroadcast();
    }
}
