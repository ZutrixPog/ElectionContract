pragma solidity >=0.6.0 <0.9.0;

contract Elections {

    enum State {
        SignUp,
        Confirmation,
        Election,
        Result,
        Canceled
    }

    struct Election {
        address owner;
        string question;
        uint totalVotes;
        uint candidatesCount;
        uint totalVoters;
        address winner;
        uint startBlock;
        uint endBlock;
        State state;
    }

    mapping (uint256 => Election) internal elections;

    uint internal currentElections;

    modifier isState(State _state, uint256 _electionId) {
        Election storage elec = elections[_electionId]; 
        require(elec.owner == address(0), "Cant find your Election");
        require(elec.state == _state); 
        _;
    }

    modifier isElecOwner(uint _electionId) {
        require(elections[_electionId].owner == msg.sender, "Your are not the election owner!");
        _;
    }
}