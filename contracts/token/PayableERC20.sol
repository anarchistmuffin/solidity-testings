// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "./BaseERC20.sol";
import "../utils/Payable.sol";

abstract contract PayableERC20 is BaseERC20, Payable {

fallback() external payable  {}

    

}