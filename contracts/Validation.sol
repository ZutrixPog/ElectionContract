pragma solidity >=0.6.0 <0.9.0;

import "./ownable.sol";
import "./ElectionOwnership.sol";

contract Validation is Elections, Ownable {
    
    mapping (uint256 => mapping(address => uint)) validators;
    mapping (uint256 => uint) internal numValidators;

    mapping (uint256 => uint) internal _totalWeight;

    modifier onlyValidator(uint256 _electionId) {
        require(validators[_electionId][msg.sender] != 0);
        _;
    }
    
    function addValidator(uint electionId, address _validator, uint _weight) external isElecOwner(electionId) isState(State.SignUp, electionId) {
        require(validators[electionId][msg.sender] != 0 && _weight <= 100);
        validators[electionId][_validator] = _weight;
        numValidators[electionId]++;
        _totalWeight[electionId] += _weight;
    }

    function removeValidator(uint electionId, address _validator) external isElecOwner(electionId) isState(State.SignUp, electionId) {
        require(validators[electionId][_validator] != 0);
        _totalWeight[electionId] -= validators[electionId][_validator];
        numValidators[electionId]--;
        validators[electionId][_validator] = 0;
    }

    function modifyWeight(uint electionId, address _validator, uint _newWeight) external isElecOwner(electionId) isState(State.SignUp, electionId) {
        require(validators[electionId][_validator] != 0 && _newWeight <= 100);
        _totalWeight[electionId] += _newWeight - validators[electionId][_validator];
        validators[electionId][_validator] = _newWeight;
    }

    function totalWeight(uint _electionId) internal returns (uint) {
        return _totalWeight[_electionId];
    }
}