pragma solidity >=0.6.0 <0.9.0;

import "./Candidate.sol";
import "./SafeMath.sol";

contract Voters is Candidates {

    using SafeMath for uint256;

    struct Voter {
        bool isValid;
        bool hasVoted;
        uint weight;
    }

    mapping (uint256 => mapping(address => Voter)) internal voters;
    mapping (uint256 => mapping(address => bool)) private hasVotedVoter;
    mapping (uint256 => address[]) internal _votersId;
    mapping (uint256 => uint) private totalVotesForVoter;

    event VoterAdded(address[] voters);

    function addVoter(uint256 electionId, address[] memory _voters) external onlyValidator(electionId) isState(State.SignUp, electionId) {
        require(elections[electionId].owner != address(0));
        Voter memory newVoter;
        for (uint i = 0; i < _voters.length; i++){
            newVoter = Voter({isValid: false, hasVoted: false, weight: 0});
            voters[electionId][_voters[i]] = newVoter;
            _votersId[electionId].push(_voters[i]);
        }
        elections[electionId].totalVoters += _voters.length;
        emit VoterAdded(_voters);
    }

    function hasVoted(uint256 electionId, address _voter) external returns (bool) {
        require(_voter == msg.sender);
        return voters[electionId][_voter].hasVoted;
    }

    function qualifyVoter(uint256 _electionId, address[] memory _voters) external onlyValidator(_electionId) isState(State.Confirmation, _electionId) {
        require(hasVotedVoter[_electionId][msg.sender] == false, "You have already Voted");
        require(_voters.length == elections[_electionId].totalVoters);
        for (uint i = 0; i <= _voters.length; i++) {
            if (voters[_electionId][_voters[i]].weight != 0)
                voters[_electionId][_voters[i]].weight += validators[_electionId][msg.sender];
        }
        hasVotedVoter[_electionId][msg.sender] = true;
        totalVotesForVoter[_electionId]++;
    }

    function tallyVoters(uint256 _electionId) internal isElecOwner(_electionId) isState(State.Confirmation, _electionId) {
        require(totalVotesForVoter[_electionId] > (numValidators[_electionId].div(10).mul(7)));
        for (uint i = 0; i <= _votersId[_electionId].length; i++) {
            voters[_electionId][_votersId[_electionId][i]].isValid = validateVoter(_electionId, _votersId[_electionId][i]);
        }
    }

    function validateVoter(uint256 _electionId, address _voter) private returns (bool) {
        return voters[_electionId][_voter].weight > (totalWeight(_electionId) / 2);
    }
}
