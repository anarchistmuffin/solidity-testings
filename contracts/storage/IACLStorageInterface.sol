// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface IACL_STORAGE_INTERFACE {


event NewRoleAddedEvent(string roleName);

  

    //function ACL_RESOURCE_ACCESS_SLOT(uint chainId,string memory name_) external returns(bytes32);

    function verifyRoleForUser(address _user, string memory _role, string memory _contractNameOrAddress) external view returns(bool);

    function isSuperAdmin(address _user) external view returns(bool);

    


}
