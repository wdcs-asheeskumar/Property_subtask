// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract UsdtMock is ERC20 {
    constructor() ERC20("MockUsdt", "USDT") {
        _mint(msg.sender, 10000000000 * (10 ** decimals()));
    }

    function mintToken(uint256 value) public {
        _mint(msg.sender, value);
    }
    function giveApproval(address _address, uint256 value) public {
        approve(_address, value);
    }

    function checkApproval(
        address owner,
        address spender
    ) public view returns (uint256) {
        return (allowance(owner, spender));
    }

    function transferFunds(address to, uint256 value) public {
        transfer(to, value);
    }

    function checkBalance(address owner) public view returns (uint256) {
        return balanceOf(owner);
    }
}
