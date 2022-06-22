// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "./IRouteController.sol";

abstract contract BaseRouteController is IRouteController {

    function _execute(bytes calldata _data) virtual external;
    function _implementFunctionID(bytes32 functionID) virtual external returns(bool);
    function _supportsRouteOpCode(bytes1 opcode) virtual external returns(bool);
    function _getAddressEndpoint(string memory _endpointName) virtual external returns(address);

    function _beforeExecuteHook() virtual external;
    function _afterExecuteHook() virtual external;

    function _canTransfer() virtual external returns(bool);
    function _canWithdraw() virtual external returns(bool);
    function _canInteractWith(address) virtual external returns(bool);
    function _routeType() virtual external returns(uint);
}