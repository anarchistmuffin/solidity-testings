// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;


import "@openzeppelin/contracts-upgradeable/proxy/beacon/IBeaconUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/ERC1967/ERC1967UpgradeUpgradeable.sol";

contract LabzBeacon is
	IBeaconUpgradeable,
    ERC1967UpgradeUpgradeable
    
{

  	/**
	 * @dev Must return an address that can be used as a delegate call target.
	 *
	 * {BeaconProxy} will check that this address is a contract.
	 */
	function implementation() public view override returns (address) {
		return _getImplementation();
	}
}