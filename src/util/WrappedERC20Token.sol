// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {ERC20Token} from "./ERC20Token.sol";

contract WrappedERC20Token is ERC20Token {
    constructor(
        string memory name,
        string memory symbol
    ) ERC20Token(name, symbol) {}

    function mint(address to, uint256 amount) external override onlyOwner {
        _mint(to, amount);
    }

    function burn(address _address, uint256 amount) external onlyOwner {
        _burn(_address, amount);
    }
}
