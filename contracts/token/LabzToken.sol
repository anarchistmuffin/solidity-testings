// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;


import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20SnapshotUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesCompUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/draft-ERC20PermitUpgradeable.sol";


contract LabzToken is ERC20Upgradeable, ERC20PermitUpgradeable, ERC20VotesCompUpgradeable, ERC20SnapshotUpgradeable {


        string internal constant NAME = "LabzToken";
        string internal constant SYMBOL = "LABZ";
        uint8 internal constant DECIMALS = 18;
        uint256 public constant REVISION = 1;

     

       function initialize() initializer public {
            __ERC20_init(NAME, SYMBOL);
            __ERC20Permit_init(NAME);
            __ERC20Votes_init();
            __ERC20Snapshot_init();

       }


      function _mint(address account, uint256 amount) internal virtual override(ERC20Upgradeable, ERC20VotesUpgradeable) {
        super._mint(account, amount);
    }

  
    function _burn(address account, uint256 amount) internal virtual override(ERC20Upgradeable, ERC20VotesUpgradeable) {
        super._burn(account, amount);
    }



       function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override(ERC20Upgradeable, ERC20VotesUpgradeable){
        super._afterTokenTransfer(from, to, amount);

    }

     function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override(ERC20Upgradeable, ERC20SnapshotUpgradeable) {
        super._beforeTokenTransfer(from, to, amount);

    }




}