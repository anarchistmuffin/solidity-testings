 // SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

library Constants {
 bytes32 public constant _OWNER_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

 function getOwnerSlot() public pure returns(bytes32)  {
    return _OWNER_SLOT;
 }


enum Roles {
   DEFAULT,
   HOLDER,
   DEVELOPER,
   MARKETING,
   ADMIN,
   SUPERADMIN,
   BANNED
}

}
 
