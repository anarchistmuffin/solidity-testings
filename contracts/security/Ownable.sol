 // SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "../constants.sol";



interface ContractIsOwnable {
    function owner() external view returns(address _owner);
}

contract Ownable is ContractIsOwnable {
// we store the owner using assembly
    constructor() {
        address _owner = msg.sender;
        bytes32 slot = Constants.getOwnerSlot();
        assembly {
            sstore(slot, _owner)
        }
    }

    function owner() public view override returns(address _owner) {
         bytes32 slot = Constants.getOwnerSlot();
         /* eslint-disable no-inline-assembly */
         assembly {
            _owner := sload(slot)
         }
    }

    modifier onlyOwner() {
        require(msg.sender == owner(), "ACCESS_DENIED");
        _;
    }

}
