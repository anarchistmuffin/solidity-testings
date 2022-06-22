// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "./IACLStorageInterface.sol";
import "../utils/ERC165.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/// @dev ACLStorage implements IACLStorageInterface

contract ACLStorage is Initializable, IACL_STORAGE_INTERFACE, IERC165 {

    mapping(string => mapping(bytes32 => bool)) private _roles;
    mapping(bytes32 => mapping(address => bool)) private _eip712Access;
    mapping(address => uint) private _nonces;
    mapping(address => mapping(bytes32 => bool)) private _hasAccess;
    mapping(string => bytes32) private _strToRoleBytes;
    mapping(address => mapping(bytes32 => bytes32)) private _hasAccessToResourceWithIdAndRole;
    mapping(address => bytes32) private _addrToRoleBytes;


    bytes32  private ACL_SLOT_STORAGE;
    bytes32 private ACL_SLOT_ENCODED_ACCESS;
    bytes32 private ACL_ROLE_GLOBAL_ADMIN;



  
    address public _superadmin;

   

    function initialize(address _globalAdminAddress) initializer public {
        __ACL_Storage_init(_globalAdminAddress);
    }


    function __ACL_Storage_init(address _globalAdminAddress) onlyInitializing public {
     ACL_ROLE_GLOBAL_ADMIN    = keccak256(abi.encode("GLOBAL_ADMIN"));
            ACL_SLOT_STORAGE = keccak256("ACLStorage(address _globalAdminAddress)");
           _addRole("GLOBAL_ADMIN", ACL_ROLE_GLOBAL_ADMIN);
           bytes32 encodedAdmin = _grantRoleToUser(_globalAdminAddress, "GLOBAL_ADMIN", "SUPER_ADMIN");
           bytes32 slot = ACL_SLOT_STORAGE;
           _superadmin = _globalAdminAddress;

                
           assembly {
               sstore(slot, encodedAdmin)
           }
       
    }

    function getSuperAdmin() public view returns(address) {
        return _superadmin;
    }

     function __ACL_Storage_init_unchained(address _globalAdminAddress) onlyInitializing public {
     
        __ACL_Storage_init(_globalAdminAddress);
     
     }

    function isSuperAdmin(address _user) public view returns(bool result) {
        bytes32 slot = ACL_SLOT_STORAGE;
   
      
       bytes32 encoded = _addrToRoleBytes[_user];
       bytes32 x;

        // @dev assembly is checking if encoded storage data is equal to the encodedACL for the role GLOBAL ADMIN
       assembly {
        x := sload(slot)
        switch eq(x,encoded)
        case true {
            result := true
        }
        case false {
            result := false
        }
       }

    }

    modifier onlySuperAdmin() {
        require(isSuperAdmin(msg.sender) == true, "ACCESS DENIED TO ACL");
        _;
    }

    function grantRole(address _user, string memory _role, string memory _contractName) public onlySuperAdmin returns(bytes32) {
      bytes32 gu = _grantRoleToUser(_user, _role, _contractName);
   
      return gu;
    }

    function getRole(string memory _description) public view ifRoleExists(_description) returns(bytes32) {
        return _roleFromString(_description);
    }

    function roleExists(string memory _description) public view  returns(bool) {
       return _roles[_description][keccak256(abi.encode(_description))] == true;
    }

    modifier ifRoleExists(string memory _description) {
        require(roleExists(_description), "invalid role name");
        _;
    }

    function addRole(string memory _description) public onlySuperAdmin {
        _addRole(_description, keccak256(abi.encode(_description)));
    }


    function _addRole(string memory _description, bytes32 _role) internal  {
        // the description must match the role bytes
        require(keccak256(abi.encode(_description)) == _role, "invalid role or description");
        require(_roles[_description][_role] != true , "role already exists");
        _roles[_description][_role] = true;
        _strToRoleBytes[_description] = _role;
        emit NewRoleAddedEvent(_description);
    }

    function _grantRoleToUser(address _user, string memory _role, string memory _contractNameOrAddress) internal returns(bytes32) {
      
        bytes32 role = getRole(_role);

       
        /// @dev resource id is computed from the 
        /// keccak256(
        /// address userRequestingAccess, 
        /// bytes32 roleRequested, 
        /// string contractNameOrAddressAsString
        /// )

        computeEncodedACL( _user, _role, _contractNameOrAddress);
        bytes32 encoded = _addrToRoleBytes[_user];
        

        _hasAccessToResourceWithIdAndRole[_user][encoded] = role;
        return encoded;
    }


    function verifyRoleForUser(address _user, string memory _role, string memory _contractNameOrAddress) public view returns(bool) {
        bytes32 role = getRole(_role);
       
        bytes32 _userEncoded = _addrToRoleBytes[_user];
         return _hasAccessToResourceWithIdAndRole[_user][_userEncoded] == role;
        
    }

    function computeEncodedACL(address _user, string memory _role, string memory _contractNameOrAddress) internal returns(bytes32) {
        bytes32 _encodedACL = keccak256(abi.encodeWithSelector(type(IACL_STORAGE_INTERFACE).interfaceId,_user, _role, _contractNameOrAddress));
        _addrToRoleBytes[_user] = _encodedACL;
        return _encodedACL;
    }

    function getUserEncodedRole(address _user) internal view returns(bytes32) {
        return _addrToRoleBytes[_user];
    }


    function _roleFromString(string memory _description) internal view returns(bytes32) {
        return _strToRoleBytes[_description];
    }





    function ACL_RESOURCE_ACCESS_SLOT(string memory name_) public view  returns (bytes32) {
        bytes memory e = abi.encodeWithSelector(type(IACL_STORAGE_INTERFACE).interfaceId, name_, block.chainid, address(this));
        return keccak256(e);
    }

    function computeDomainSeparator(string memory name_) internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256("EIP712DomainACL(string name,string version,uint256 chainId,address verifyingContract, bytes32 role)"),
                    keccak256(bytes(name_)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }

     function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return 
        interfaceId == type(IACL_STORAGE_INTERFACE).interfaceId ||
        interfaceId == type(IERC165).interfaceId;
    }


}