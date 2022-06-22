 // SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

abstract contract Payable {

    event Deposit(address indexed _from,  uint256 _amount);

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

}