// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

/// @title UserStorage defines a user storage contract object
/// @author anarchistmuffin
/// @notice store the user data

import {EIPVersioning} from "../utils/draft-EIPVersioning.sol";

interface UserMetadata {

    function id(address _a) external returns(bytes32);
    function username(address _a) external returns(string memory);
    function status(address _a) external returns(string memory);
    function nftAvatar(address _a) external returns(string memory);
    function setId(address _userAddress, bytes memory data) external;

}


contract UserStorage is EIPVersioning, UserMetadata {

    uint private constant VERSION = 0x1;

    mapping(address => bool) private _allowedControllers;
    mapping(address => uint) private _nonces;

    bytes32[] ids;
    mapping(address => bytes32) private _userids;
    mapping(bytes32 => bool) private _idExists;
    mapping(address => bool) private _registeredUsers;
    mapping(address => string) private _usernames;
    mapping(address => string) private _statuses;
    mapping(address => string) private _nftAvatars;
    mapping(address => string) private _descriptions;

    mapping(string => bool) private _username;

    
    struct nonce {
        uint _value;
    }

    nonce _nonce;

    constructor() EIPVersioning(VERSION) {

        _nonce = nonce(0);

    }

    function incrementNonce() internal {
        uint n = currentNonce();
        _nonce = nonce(n+1);
    }

    function currentNonce() internal view returns(uint) {
        return _nonce._value;
    }

    modifier isAllowed() {
        require(_allowedControllers[msg.sender] == true, "");
        _;
    }

    function id(address _a) public override view returns(bytes32) {
        return _userids[_a];
    }

    function setId(address _userAddress, bytes memory data) public isAllowed override {

        bytes32 newId = keccak256(abi.encode(data, currentNonce()));
        require(_idExists[newId] == false, "id already taken");
        require(_registeredUsers[_userAddress] != true, "user already registered");
        _idExists[newId] = true;
        _nonces[_userAddress] = currentNonce();
        _userids[_userAddress] = newId;
        incrementNonce();
        
    }

     function username(address _a) public override view returns(string memory) {
        return _usernames[_a];
     }

       function setUsername(address _a, string memory username_) public isAllowed  {
        _usernames[_a] = username_;
        _username[username_] = true;
     }
   
        function status(address _a) public override view returns(string memory) {
            return _statuses[_a];
        }


 function setStatus(address _a, string memory status_) public isAllowed  {
        _statuses[_a] = status_;
       
     }

      function setAvatar(address _a, string memory avatar_) public isAllowed  {
        _nftAvatars[_a] = avatar_;
       
     }

    function nftAvatar(address _a) public override view returns(string memory) {
        return _nftAvatars[_a];
    }

    function isUserRegistered(address _a) public  view returns(bool) {
        return _registeredUsers[_a];
    }

    function isUserNameTaken(string memory username_) public view returns(bool) {
        return _username[username_];
    }

    function description(address _a) public view returns(string memory) {
        return _descriptions[_a];
    }

    function setDescription(address _a, string memory description_) public isAllowed {
        _descriptions[_a] = description_;
    }



}