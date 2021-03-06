pragma solidity >=0.6.0 <0.9.0;

import "./Voter.sol";

contract Election is Voters {

    uint private Cost;

    constructor(uint _cost) public {
        Cost = _cost;
    }

    function hashElection(address _owner, string memory _question, string memory _name) pure internal returns (uint256) {
        return uint256(keccak256(abi.encodePacked(_owner, _question)));
    }

    function setCost(uint _newCost) external onlyOwner() {
        Cost = _newCost;
    }

    function getCost() external returns(uint) {
        return Cost;
    }

    function withdraw() external onlyOwner() {
        address _owner = owner();
        payable(_owner).transfer(address(this).balance);
    }

    function changeStateToConfirmation(uint256 _electionId) external isElecOwner(_electionId) {
        require(elections[_electionId].state == State.SignUp);
        elections[_electionId].state = State.Confirmation;
    } 

    function initializeElection(string memory _name, string memory _question) external payable returns(uint256) {
        require(currentElections <= 3, "Max Number of Elections reached!");
        uint elec = hashElection(msg.sender, _question, _name);
        require(elections[elec].owner != msg.sender, "Election Already Exists!");
        require(msg.value > Cost);

        elections[elec] = Election({owner: msg.sender, question: _question, state: State.SignUp, totalVotes: 0, candidatesCount: 0, totalVoters: 0, winner: address(0), startBlock: 0, endBlock: 0});
        validators[elec][msg.sender] = 1;
        return elec;
    }

    function startElection(uint256 _electionId, uint _duration) external isElecOwner(_electionId) isState(State.Confirmation, _electionId) {
        Election storage elec = elections[_electionId];
        tallyCandidates(_electionId);
        tallyVoters(_electionId);
        elec.state = State.Election;
        elec.startBlock = block.number;
        elec.endBlock =  block.number + _duration;
    }

    function castVote(uint256 _electionId, address _candidate) external isState(State.Election, _electionId) {
        require(elections[_electionId].startBlock < block.number && elections[_electionId].endBlock > block.number, "Election hasnt started or already ended!");
        Voter storage voter = voters[_electionId][msg.sender];
        require(voter.isValid && candidates[_electionId][_candidate].isValid && !voter.hasVoted);
        //require(_candidate.length <= elections[_electionId].totalCandidates);
        candidates[_electionId][_candidate].voteCount++;
        elections[_electionId].totalVotes++;
    }

    function concludeElection(uint256 _electionId) external isElecOwner(_electionId) isState(State.Election, _electionId) returns(address){
        require(block.number > elections[_electionId].endBlock, "Election time isnt over!");
        address[] storage ids = candidatesId[_electionId];
        address winner = ids[0];
        for (uint i = 1; i < ids.length; i++){
            if (candidates[_electionId][winner].voteCount < candidates[_electionId][ids[i]].voteCount) {
                winner = ids[i];
            }
        }
        elections[_electionId].state = State.Result;
        elections[_electionId].winner = winner;
        return winner;
    }
}
