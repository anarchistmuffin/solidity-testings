// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "../token/BaseERC20.sol";

contract StakesStorage {

    address[] internal _stakeHolders;

    struct Stake {
        address _stakedToken;
        uint256 _stakedAmount;
        uint _stakeAtTime;
        uint _expiresAt;
    }

    struct Interest {
        address _interestRateContract;
        uint256 accruedInterest;
        bool _claimed;
    }

  
    mapping(address => uint256) private _stakeHolder;
    mapping(address => mapping(uint => Stake)) private _stakeDetails;
    mapping(address => Index) private _userIndexCount;
    mapping(address => bool) private _isStakeHolder;
    mapping(address => uint256) private _rewards;

    struct Index {
        uint _value;
    }

    Index private _index;

    uint256 public totalStakesValue;

    constructor() {
        _index = Index(0);
        totalStakesValue = 0;
    }

    function currentIndex() internal view returns(uint) {
        return _index._value;
    }

    function currentIndex(address _a) internal view returns(uint) {
        return _userIndexCount[_a]._value;
    }

    function incrementIndex() internal {
        uint current = currentIndex();
        _index = Index(current + 1);
    }

       function incrementIndex(address _a) internal {
        uint current = _userIndexCount[_a]._value;
        _userIndexCount[_a] = Index(current + 1);
    }

    function _stake(address _sender, address _token, uint256 _amount, uint expirationInDays) internal  {

        BaseERC20(_token).burn(msg.sender, _amount);

        if(_isStakeHolder[_sender] != true) {
            // we init the new stake holder
            _userIndexCount[_sender] = Index(0);
            _stakeHolders[currentIndex()] = _sender;
            _stakeHolder[_sender] = 0;
            _isStakeHolder[_sender] = true;

        }

        Stake memory stake = Stake(_token, _amount, block.timestamp, block.timestamp + (expirationInDays * 1 days));
        _stakeHolder[_sender] += _amount;
      
        _stakeDetails[_sender][currentIndex(_sender)] = stake;
         incrementIndex();
        totalStakesValue += _amount;
        
    }

    function newStake(address _token, uint expirationInDays) public payable {
        require(msg.sender != address(0), "cannot stake");
        require(msg.value > 100 * 10 ** 18, "you need to stake at least 100 tokens");
        require(expirationInDays >= 30, "you need to stake for at least 30 days");
       
        _stake(msg.sender, _token, msg.value, expirationInDays);
    }

    function calculateRewards(address _holder) internal returns (uint256) {

        uint256 amt = 0;
        uint256 reward = 0;
        uint256 rate = 50; // 0.5% interest rate
        uint256 bonusPerDay = 333; // 3.33% bonus per day = ~100% per month
        for(uint j = 0; j < currentIndex(_holder); j++) {
            Stake storage details = _stakeDetails[_holder][j];
            amt += details._stakedAmount;
            reward += (amt * rate) / 1e4;
            uint currentTime = block.timestamp;
            uint numDays = (currentTime - details._stakeAtTime) /  1 days;
            reward += (numDays * (amt * bonusPerDay) / 1e4);
        }

        _rewards[_holder] = amt;

        return reward;

    }

    function withdrawable(address _holder) internal view returns(uint256) {

        uint w = 0; // withdrawable amount
        uint s = 0; // slashable amount or penalty

         for(uint j = 0; j < currentIndex(_holder); j++) {
            Stake storage details = _stakeDetails[_holder][j];
            if(block.timestamp >= details._expiresAt) {
            w += details._stakedAmount;
            }
            if(block.timestamp < details._expiresAt) {
                s += (details._stakedAmount * 25) / 1e4;
            }
          
        }

        uint wRewards = _rewards[_holder] - s;
        return w + wRewards;

    }

    function withdrawableRewards(address _holder) internal view returns(uint256) {

        uint s = 0; // slashable amount or penalty

         for(uint j = 0; j < currentIndex(_holder); j++) {
            Stake storage details = _stakeDetails[_holder][j];
    
            if(block.timestamp < details._expiresAt) {
                s += (details._stakedAmount * 25) / 1e4;
            }
          
        }

        uint wRewards = _rewards[_holder] - s;
        return wRewards;

    }

    function getWithdrawableAmount() public view returns(uint256) { 
        return withdrawable(msg.sender);
    }

    function canWithdraw() public view returns (bool) {
        return withdrawable(msg.sender) > 0;
    }

    function withdrawRewards(address _token) public payable {

        uint256 rewards = withdrawableRewards(msg.sender);
        rewards = 0;
        BaseERC20(_token).mint(msg.sender, rewards);

    }

}