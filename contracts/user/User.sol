// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

/// @title User defines a user logic and uses UserStorage for data storage
/// @author anarchistmuffin
/// @notice store the user data

import {UserStorage} from "../storage/UserStorage.sol";

contract User {

    UserStorage private userStorage;

    function setStorageContract(address _userStorageAddress) public {

        userStorage = UserStorage(_userStorageAddress);
    
    }

    function isMyAddressRegistered() public view returns(bool)  {
        return userStorage.isUserRegistered(msg.sender);
    }

    function isMyUserNameAvailable(string memory username) public view returns(bool) {
        return userStorage.isUserNameTaken(username) != true;
    }

    function getUserName(address _a) public view returns(string memory) {
        return userStorage.username(_a);
    }

    function getId(address _a) public view returns(bytes32) {
        return userStorage.id(_a);
    }

    function getStatus(address _a) public view returns(string memory) {
        return userStorage.status(_a);
    }

    function getAvatar(address _a) public view returns(string memory) {
        return userStorage.nftAvatar(_a);
    }

    function getDescription(address _a) public view returns(string memory) {
        return userStorage.description(_a);
    }

    function registerNewUser(address _a, string memory username_, string memory description_, string memory status_, string memory avatar_) public {
        userStorage.setId(_a, abi.encode(block.timestamp));
        userStorage.setUsername(_a, username_);
        userStorage.setDescription(_a, description_);
        userStorage.setStatus(_a, status_);
        userStorage.setAvatar(_a, avatar_);
    }


}