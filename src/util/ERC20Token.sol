// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {ERC20} from "oz/token/ERC20/ERC20.sol";
import {Ownable} from "oz/access/Ownable.sol";

contract ERC20Token is ERC20, Ownable {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(address to, uint256 amount) external virtual onlyOwner {
        _mint(to, amount);
    }
}
