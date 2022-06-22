// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface IRouteController {

    function _execute(bytes calldata _data) external;
    function _implementFunctionID(bytes32 functionID) external returns(bool);
    function _supportsRouteOpCode(bytes1 opcode) external returns(bool);
    function _getAddressEndpoint(string memory _endpointName) external returns(address);

    function _beforeExecuteHook() external;
    function _afterExecuteHook() external;

    function _canTransfer() external returns(bool);
    function _canWithdraw() external returns(bool);
    function _canInteractWith(address) external returns(bool);
    function _routeType() external returns(uint);


}

interface IRouteCanReply is IRouteController {
     function _approveSenderBeforeReplying() external;
     function _prepareReply() external;
     function _sendReply(address _to, bytes32 reqId, bytes calldata _data) external;

}