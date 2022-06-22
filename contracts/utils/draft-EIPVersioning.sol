// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "../security/Ownable.sol";

interface IEIPVersioning {

    event VersionUpdated(uint oldVer, uint version, uint blockNumber);
    
  
    function _getVersionHash() external returns (bytes32);
    function updateVersion(uint newVersion) external;


}

contract EIPVersioning is IEIPVersioning, Ownable {

    bytes32 private VERSION_STORAGE_SLOT;
    uint private _version;
    mapping(uint => bytes32) private _versionHashSnapshots;
    mapping(bytes32 => mapping(uint => bool)) private _validVersions;

    constructor( uint versionNumber) {
        VERSION_STORAGE_SLOT =  keccak256("EIPVersioning(bool isNew, bool isUpdate, uint versionNumber)");
        _setVersion(versionNumber);
    }

    function _setVersion(uint ver) internal  {
        bytes32 slot = VERSION_STORAGE_SLOT;
        assembly {
            
            sstore(slot, ver)
        }
      

    }

    function _getVersion() internal view returns (uint ver) {
         bytes32 slot = VERSION_STORAGE_SLOT;
        assembly {
           ver := sload(slot)
        }
    }

    function _verify(bytes32 _givenVersionHash) internal {}


    function _getVersionHash() public view  override returns(bytes32) {
        return _versionHashSnapshots[_version];
    }
    function _setVersionHash(bytes32 _previousVersionHash) internal {
        bytes32 _versionHash = (keccak256(abi.encodePacked(_previousVersionHash, _getVersion())));
        _versionHashSnapshots[_version] = _versionHash;
    }
   
    function _updateVersion(uint  newVersion) internal {
            uint oldVer = _getVersion();
            _setVersion(newVersion);
            emit VersionUpdated(oldVer, newVersion, block.number);
    }

    function updateVersion(uint newVersion) public override onlyOwner {
        _updateVersion(newVersion);
    }


}