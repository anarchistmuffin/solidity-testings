// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import {IRouteCanReply} from "../IRouteController.sol";

abstract contract Replyable is IRouteCanReply {

     mapping(bytes32=>bool) private _responseSent;
     mapping(bytes32=>bytes) private _responseHistory;
     mapping(bytes32=>bool) private _forGarbageCollection;

     function _approveSenderBeforeReplying() virtual external;
     function _prepareReply() virtual external;
     function _sendReply(address _to, bytes32 reqId, bytes calldata _data) virtual external;

}