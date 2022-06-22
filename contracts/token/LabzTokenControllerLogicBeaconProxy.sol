// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "../storage/ACLStorage.sol";
import "@openzeppelin/contracts-upgradeable/proxy/ERC1967/ERC1967UpgradeUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/beacon/IBeaconUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "./LabzToken.sol";

contract LabzTokenControllerLogicBeaconProxy is
	IBeaconUpgradeable,
	ERC1967UpgradeUpgradeable
	
{
	using AddressUpgradeable for address;
	address public _acl;
	address public _underlyingToken;

	function initialize(
		address _aclImplementation,
		address _token
	) public initializer {
		
		_acl =_aclImplementation;
		_underlyingToken =_token;
		
        
	}


	function getUnderlyingToken()
		public
		view
		returns (address)
	{
		return _underlyingToken;
	}



	/**
	 * @dev Must return an address that can be used as a delegate call target.
	 *
	 * {BeaconProxy} will check that this address is a contract.
	 */

  	/**
	 * @dev Must return an address that can be used as a delegate call target.
	 *
	 * {BeaconProxy} will check that this address is a contract.
	 */
	function implementation() public view override returns (address) {
		return _getImplementation();
	}
}
