// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract Vote is Ownable, AccessControl {

    uint256 voteFee;
    uint256 candidateNum;
    uint256 voterNum;
    uint256 electionNum;
    
    string [] public party = ["APC", "PDP", "LP", "NNPP"];

    bytes32 public constant INEC_EXEC_ROLE = keccak256("INEC_EXEC");
    bytes32 public constant VOTER_ROLE = keccak256("VOTER");

    struct candidate {
        string name;
        address addr;
        string party;
    }

    struct voter {
        address addr;
        uint256 nin;
        uint256 partyNum;
        bool hasVoted;
    }

    struct election {
        address [] candidate;
        uint256 [] candidateVote;
        uint256 start;
        uint256 duration;
        bool hasEnded;
    }

    // mapping of candidates to keep track of how many candidates there are
    mapping(uint256 => candidate) public Candidates;

    // mapping of voters to keep track of how many voters there are
    mapping(uint256 => voter) public Voters;
    
    // mapping of election to keep track of how many elections there are
    mapping(uint256 => election) internal Elections;

    /**
     * @dev checks to see if the address is an INEC executive
     */
    modifier isInecExec () {
        require(hasRole(INEC_EXEC_ROLE, msg.sender), "Caller is not an INEC executive");
        _;
    }


    constructor() {
        // Grant the contract deployer the default admin role: it will be able
        // to grant and revoke any roles
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /**
     * @dev Grant INEC executive role to an address 
     * @param _account value for the role'
     */
    function createInecExec(address _account) public onlyOwner{
        grantRole(INEC_EXEC_ROLE, _account);
    }
    

    /**
     * @dev Store value in variable
     * @param name value for candidate name
     * @param candAddress value for candidate Address
     * @param partyNum value for candidate party
     */
    function createCandidate(string memory name, address candAddress, uint256 partyNum) public isInecExec {
        Candidates[candidateNum].name = name;
        Candidates[candidateNum].addr = candAddress;
        Candidates[candidateNum].party = party[partyNum]; 

        candidateNum ++;      
    }


    /**
     * @dev registers a voter
     * @param _account address of voter, _nin is the voters identifier'
     */
    function regVoter(address _account, uint256 _nin) public {
        Voters[voterNum].addr = _account;
        Voters[voterNum].nin = _nin;

        _setupRole(VOTER_ROLE, _account);
    }

    /**
     * @dev registers a voter
     * @param _candidateNum is an arrat of candidates, _nin is the voters identifier'
     */
    function createElection(address[] memory _candidateNum, uint256 _date, uint256 _duration) public isInecExec {
       Elections[electionNum].start = _date;
       Elections[electionNum].duration = _duration;

       for(uint i = 0; i < _candidateNum.length; i++){
           Elections[electionNum].candidate.push(_candidateNum[i]);
       }

       electionNum ++;
    }


    /**
     * @dev Return value 
     * @return value of 'struct'
     */
    function retrieveCandidate(uint256 num) public view returns (candidate memory){
        return Candidates[num];
    }

    /**
     * @dev Return value 
     * @return value of 'struct'
     */
    function getElection(uint256 num) public view returns (election memory){
        return Elections[num];
    }


   
}