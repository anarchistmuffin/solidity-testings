// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "@openzeppelin/contracts/utils/Address.sol";

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";


contract RouteRegistry  {

    using Address for address;

    bytes4 private rm;

    mapping(string => bytes1) private _routeTypeBytes;
    mapping(bytes1 => bool) private _opcodeExists;
    mapping(bytes4 => address) private _routeToController;
    mapping(bytes4 => bool) private _ctrlExists;
    mapping(bytes32 => bool) private _reqIds;
    mapping(bytes32 => request) private _requests;
    mapping(bytes32 => response) private _responses;
    
    /// @dev route is 14 bytes long
    struct route {
        bytes4 _magic;
        bytes1 _typeByte;
        bytes4 _controllerInterfaceId;
        bytes1 _isCalldata;
        bytes4 _callType;
    }

    struct paramsKey {
        bytes4 _supportedKeyInterface;
        bytes32 _keyValue;
    }

    struct paramsValue {
        bytes _value;
        uint size;
    }

    struct routeParams {
        paramsKey[] _keys;
        paramsValue[] _values;
    }

    struct request {
        bytes32 ID;
        bytes _routeData;
        routeParams _routeParams;
        address _sender;
        address _sentToAddress;
        uint _underlyingValue;
    }

    struct response {
        bytes32 reqID;
        address _from;
        address _to;
        bytes _respData;
        uint _errorCode;
        string _errorMsg;
    }


    
    mapping(string => bool) private _routeExists;

    function _onReceivedRouteRequest(address _sender, bytes calldata _request) internal view  {

       request memory decodedReq = abi.decode( _request, (request));
       require(_sender == decodedReq._sender, "forged request protection: request seems dangerous");
       require(decodedReq.ID.length == 32, "invalid ID");
       require(_reqIds[decodedReq.ID] != true, "replay protection: request id already exists");
       _afterRequestDecoding(decodedReq);
    }

    function _afterRequestDecoding(request memory decodedReq) internal view  {

        route memory routeData = _decodeRoute(decodedReq);
        require(_routeIsValid(routeData) == true, "");



    }

    function _decodeRoute(request memory decodedReq) internal pure returns(route memory) {

        route memory routeData = abi.decode(decodedReq._routeData, (route));
        return routeData;

    }

/// @notice if route is not valid it will revert with the error message
  function _routeIsValid(route memory decodedRoute) internal view returns(bool) {
        require(decodedRoute._magic == rm, "invalid route magic");
        require(_opcodeExists[decodedRoute._typeByte] == true, "invalid opcode");
        require(_ctrlExists[decodedRoute._controllerInterfaceId] == true, "invalid controller interface id");
        return true;

    }

    modifier onlyRouter() {
        require(Address.isContract(msg.sender), "only contracts are allowed here");
        _;
    }


  

    fallback () external {
        _onReceivedRouteRequest(msg.sender, msg.data);
    }

}
