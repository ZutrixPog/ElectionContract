pragma solidity >=0.6.0 <0.9.0;

import "./Validation.sol";
import "./SafeMath.sol";

contract Candidates is Validation {

    using SafeMath for uint256;

    struct Candidate {
        string name;
        uint8 group;
        uint32 voteCount;
        bool isValid;
        uint weight;
    }

    mapping (uint256 => mapping(address => Candidate)) candidates;
    mapping (uint256 => mapping(address => bool)) hasVotedCandidate;
    mapping (uint256 => address[]) internal candidatesId;
    mapping (uint256 => uint) private totalVotesForCandidate;

    // Events
    event CandidateAdded(address[] candidates);

    function addCandidate(uint256 _electionId, address[] memory _candidates, uint8 _group, string memory _name) external onlyValidator(_electionId) isState(State.SignUp, _electionId) {
        _addCandidate(_electionId, _candidates, _group, _name);
    }

    function removeCandidate(uint256 _electionId, address _candidate) external isState(State.SignUp, _electionId) {
        require(msg.sender == owner() || msg.sender == _candidate);
        delete candidates[_electionId][_candidate];
    }

    function getCandidateInfo(uint256 _electionId, address _candidate) external view returns (Candidate memory) {
        return candidates[_electionId][_candidate];
    }

    function qualifyCandidates(uint256 _electionId, address[] memory _candidatesId) external onlyValidator(_electionId) isState(State.Confirmation, _electionId) {
        require(hasVotedCandidate[_electionId][msg.sender] == false);
        require(_candidatesId.length == elections[_electionId].candidatesCount);
        for (uint i = 0; i <= _candidatesId.length; i++) {
            if (candidates[_electionId][_candidatesId[i]].weight != 0)
                candidates[_electionId][_candidatesId[i]].weight += validators[_electionId][msg.sender];
        }
        hasVotedCandidate[_electionId][msg.sender] = true;
        totalVotesForCandidate[_electionId]++;
    }

    function tallyCandidates(uint256 _electionId) internal isElecOwner(_electionId) isState(State.Confirmation, _electionId) {
        require(totalVotesForCandidate[_electionId] > numValidators[_electionId].div(10).mul(7));
        for (uint i = 0; i <= candidatesId[_electionId].length; i++) {
            candidates[_electionId][candidatesId[_electionId][i]].isValid = validateCandidate(_electionId, candidatesId[_electionId][i]);
        }
    }

    function validateCandidate(uint256 _electionId, address _candidate) internal returns (bool) {
        uint d = totalWeight(_electionId) / 2;
        return candidates[_electionId][_candidate].weight > d;
    }

    function _addCandidate(uint256 electionId, address[] memory _candidates, uint8 _group, string memory _name) private isState(State.SignUp, electionId) {
        Candidate memory newCandidate;
        for (uint i = 0; i < _candidates.length; i++){
            newCandidate = Candidate({name: _name, group: _group, voteCount: 0, isValid: false, weight: 0});
            candidates[electionId][_candidates[i]] = newCandidate;
            candidatesId[electionId].push(_candidates[i]);
        }
        elections[electionId].candidatesCount += _candidates.length;
        emit CandidateAdded(_candidates);
    }
}
