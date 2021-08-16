
// We will be using Solidity version 0.5.4
pragma solidity 0.5.4;
// Importing OpenZeppelin's SafeMath Implementation
import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.4.0/contracts/math/SafeMath.sol#L1';
// import "@openzeppelin/contracts/utils/math/SafeMath.sol";


contract Crowdfunding {
    using SafeMath for uint256;

    // list of projects
    // add on when a project is created
    Project[] private projects;

    // emitted on startProject()
    event ProjectStarted(
        address contractAddress,
        address projectStarter,
        string projectTitle,
        string projectDesc,
        uint256 deadline,
        uint256 goalAmount
    );

   
    function startProject(
        string calldata title,
        string calldata description,
        uint durationInDays,
        uint amountToRaise
    ) external {
        uint raiseUntil = now.add(durationInDays.mul(1 days));
        Project newProject = new Project(msg.sender, title, description, raiseUntil, amountToRaise);
        
        projects.push(newProject); // this the part that updates
        
        emit ProjectStarted(
            address(newProject),
            msg.sender,
            title,
            description,
            raiseUntil,
            amountToRaise
        );
    }                                                                                                                                   


    // call this on frontend to get list of projects
    // later go through one by one
    function returnAllProjects() external view returns(Project[] memory){
        return projects;
    }
}


contract Project {
    using SafeMath for uint256;
    
    // Data structures
    enum State {
        Fundraising,
        Expired,
        Stage1, // stagw 1 complete
        Successful // stage 2 complete
    }

    // State variables
    Ballot[] private ballots;
    address payable public creator;
    uint public amountGoal; // required to reach at least this much, else everyone gets refund
    uint public completeAt;
    uint256 public currentBalance;
    uint public raiseBy;
    string public title;
    string public description;
    State public state = State.Fundraising; // initialize on create
    mapping (address => uint) public contributions;
    address[] public contributors;


    event FundingReceived(address contributor, uint amount, uint currentTotal);

    // hardcoded 2 stages only
    event CreatorPaidStage1(address recipient);
    event CreatorPaidStage2(address recipient);
    
    // Event emitted when a ballot is created
    event BallotStarted(
        address contractAddress,
        address chairperson,
        address[] voters
    );

    // check current state
    modifier inState(State _state) {
        require(state == _state);
        _;
    }

    modifier isCreator() {
        require(msg.sender == creator);
        _;
    }

    constructor
    (
        address payable projectStarter,
        string memory projectTitle,
        string memory projectDesc,
        uint fundRaisingDeadline,
        uint goalAmount
    ) public {
        creator = projectStarter;
        title = projectTitle;
        description = projectDesc;
        amountGoal = goalAmount;
        raiseBy = fundRaisingDeadline;
        currentBalance = 0;
    }


    function contribute() external inState(State.Fundraising) payable {
        // require(msg.sender != creator);
        contributions[msg.sender] = contributions[msg.sender].add(msg.value);
        contributors.push(msg.sender);
        currentBalance = currentBalance.add(msg.value);
        emit FundingReceived(msg.sender, msg.value, currentBalance);
        checkIfFundingCompleteOrExpired();
    }

    // call every time contribute() is called
    function checkIfFundingCompleteOrExpired() public {
        if (currentBalance >= amountGoal) {
            state = State.Stage1;
            payOutStage1();
        } else if (now > raiseBy)  {
            state = State.Expired;
        }
        completeAt = now;
    }

    // one shot pay everything function, might enable later?
    // function payOut() internal inState(State.Successful) returns (bool) {
    //     uint256 totalRaised = currentBalance;
    //     currentBalance = 0;

    //     if (creator.send(totalRaised)) {
    //         emit CreatorPaid(creator); // will need 2 separate events
    //         return true;
    //     } else {
    //         currentBalance = totalRaised;
    //         state = State.Successful;
    //     }

    //     return false;
    // }
    
    function payOutStage1() internal inState(State.Stage1) returns (bool) {
        uint256 totalRaised = currentBalance;
        uint256 stage1Amount = currentBalance/2;
        currentBalance = currentBalance/2; // if things fuck up look at this line

        if (creator.send(stage1Amount)) {
            emit CreatorPaidStage1(creator);
            return true;
        } else {
            currentBalance = totalRaised;
            state = State.Stage1;
        }

        return false;
    }
    
    // final payment
    function payOutStage2() internal inState(State.Successful) returns (bool) {
        // uint256 totalRaised = currentBalance;
        uint256 stage2Amount = currentBalance;
        currentBalance = 0; 

        if (creator.send(stage2Amount)) {
            emit CreatorPaidStage2(creator);
            return true;
        } else {
            currentBalance = stage2Amount;
            state = State.Successful;
        }

        return false;
    }

    
    function getRefund() public inState(State.Expired) returns (bool) {
        require(contributions[msg.sender] > 0);

        uint amountToRefund = contributions[msg.sender];
        contributions[msg.sender] = 0;

        if (!msg.sender.send(amountToRefund)) {
            contributions[msg.sender] = amountToRefund;
            return false;
        } else {
            currentBalance = currentBalance.sub(amountToRefund);
        }

        return true;
    }
    
    
    // front end iterate through list of projects and call this for each project
    function getDetails() public view returns 
    (
        address payable projectStarter,
        string memory projectTitle,
        string memory projectDesc,
        uint256 deadline,
        State currentState,
        uint256 currentAmount,
        uint256 goalAmount
    ) {
        projectStarter = creator;
        projectTitle = title;
        projectDesc = description;
        deadline = raiseBy;
        currentState = state;
        currentAmount = currentBalance;
        goalAmount = amountGoal;
    }
    
    function getContributors() public view returns
    (
        address[] memory projectContributors
    ) {
        projectContributors = contributors;
    }
    
    
    // Adding the voting components from here on
    
    // struct Voter {
    //     uint weight; // weight is accumulated by delegation
    //     bool voted;  // if true, that person already voted
    //     address delegate; // person delegated to
    //     uint vote;   // index of the voted proposal
    // }
    
    function startVote() external {
        // uint raiseUntil = now.add(durationInDays.mul(1 days));
        require(msg.sender == creator);
        address payable chair = creator;
        address[] memory voters = contributors;
        
        Ballot newBallot = new Ballot(chair, voters);
        
        
        // Project newProject = new Project(msg.sender, title, description, raiseUntil, amountToRaise);
        // projects.push(newProject);
        ballots.push(newBallot);
        
        
        emit BallotStarted(
            address(newBallot),
            chair,
            voters
        );
    }
    
    
}

contract Ballot {

    struct Voter {
        uint weight; // weight is accumulated by delegation
        bool voted;  // if true, that person already voted
        address delegate; // person delegated to
        uint vote;   // index of the voted proposal
    }

    // This is a type for a single proposal.
    struct Proposal {
        string name;   // short name (up to 32 bytes)
        uint voteCount; // number of accumulated votes
    }

    address public chairperson;

    // This declares a state variable that
    // stores a `Voter` struct for each possible address.
    mapping(address => Voter) public voters;

    // A dynamically-sized array of `Proposal` structs.
    Proposal[] public proposals;

    /// Create a new ballot to choose one of `proposalNames`.
    constructor(address payable creator, address[] memory contributors ) public {
        // chairperson = msg.sender;
        chairperson = creator;
        voters[chairperson].weight = 1;

        // For each of the provided proposal names,
        // create a new proposal object and add it
        // to the end of the array.
            // `Proposal({...})` creates a temporary
            // Proposal object and `proposals.push(...)`
            // appends it to the end of `proposals`.
        proposals.push(Proposal({
            name: "yes",
            voteCount: 0
        }));
        proposals.push(Proposal({
            name: "no",
            voteCount: 0
        }));
        
        for (uint i = 0; i < contributors.length; i++) {
            // add all addresses in contributors list to the voters list
            address voter = contributors[i];
            voters[voter].weight = 1;
        }
    }

    // Give `voter` the right to vote on this ballot.
    // May only be called by `chairperson`.
    function giveRightToVote(address voter) public {
        // If the first argument of `require` evaluates
        // to `false`, execution terminates and all
        // changes to the state and to Ether balances
        // are reverted.
        // This used to consume all gas in old EVM versions, but
        // not anymore.
        // It is often a good idea to use `require` to check if
        // functions are called correctly.
        // As a second argument, you can also provide an
        // explanation about what went wrong.
        require(
            msg.sender == chairperson,
            "Only chairperson can give right to vote."
        );
        require(
            !voters[voter].voted,
            "The voter already voted."
        );
        require(voters[voter].weight == 0);
        voters[voter].weight = 1;
    }


    /// Give your vote (including votes delegated to you)
    /// to proposal `proposals[proposal].name`.
    function vote(uint proposal) public {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Has no right to vote");
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = proposal;

        // If `proposal` is out of the range of the array,
        // this will throw automatically and revert all
        // changes.
        proposals[proposal].voteCount += sender.weight;
    }

    /// @dev Computes the winning proposal taking all
    /// previous votes into account.
    function winningProposal() public view
            returns (uint winningProposal_)
    {
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }

    // Calls winningProposal() function to get the index
    // of the winner contained in the proposals array and then
    // returns the name of the winner
    function winnerName() public view
            returns (string memory winnerName_)
    {
        winnerName_ = proposals[winningProposal()].name;
    }
}