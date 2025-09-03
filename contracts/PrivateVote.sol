// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

/// @title PrivateVote (Commit–Reveal Demo)
/// @notice Simple private voting for a single yes/no proposal using commit–reveal.
/// @dev "Privacy" here is through commitments (hashes). No on-chain encryption/FHE.
contract PrivateVote {
    // --------------------------------------------------------
    // Events
    // --------------------------------------------------------
    event Committed(address indexed voter);
    event Revealed(address indexed voter, bool vote);
    event Finalized(uint256 yesCount, uint256 noCount);

    // --------------------------------------------------------
    // Storage
    // --------------------------------------------------------
    string public proposal;            // e.g., "Will Bitcoin reach $100K?"
    uint256 public commitDeadline;     // timestamp when commit phase ends
    uint256 public revealDeadline;     // timestamp when reveal phase ends

    // Commitments: keccak256(abi.encode(vote,bool, salt, msg.sender))
    mapping(address => bytes32) public commitments;
    mapping(address => bool)    public hasRevealed;

    uint256 public yesCount;
    uint256 public noCount;

    bool public finalized;

    // --------------------------------------------------------
    // Construction
    // --------------------------------------------------------
    /// @param _proposal The question being voted on.
    /// @param commitDuration Seconds for commit phase.
    /// @param revealDuration Seconds for reveal phase (after commit).
    constructor(string memory _proposal, uint256 commitDuration, uint256 revealDuration) {
        require(bytes(_proposal).length > 0, "Proposal required");
        require(commitDuration > 0 && revealDuration > 0, "Durations > 0");
        proposal = _proposal;
        commitDeadline = block.timestamp + commitDuration;
        revealDeadline = commitDeadline + revealDuration;
    }

    // --------------------------------------------------------
    // Phases
    // --------------------------------------------------------
    enum Phase { Commit, Reveal, Finished }

    function currentPhase() public view returns (Phase) {
        if (block.timestamp <= commitDeadline) return Phase.Commit;
        if (block.timestamp <= revealDeadline) return Phase.Reveal;
        return Phase.Finished;
    }

    // --------------------------------------------------------
    // Voting (Commit–Reveal)
    // --------------------------------------------------------

    /// @notice Commit a vote without revealing it.
    /// @dev Commitment must be keccak256(abi.encode(vote,bool, salt, msg.sender)).
    ///      Each address can commit exactly once.
    /// @param commitment The vote commitment hash.
    function commitVote(bytes32 commitment) external {
        require(currentPhase() == Phase.Commit, "Not in commit phase");
        require(commitments[msg.sender] == bytes32(0), "Already committed");
        commitments[msg.sender] = commitment;
        emit Committed(msg.sender);
    }

    /// @notice Reveal a previously committed vote.
    /// @param vote true = YES, false = NO
    /// @param salt secret salt used to build the commitment
    function revealVote(bool vote, bytes32 salt) external {
        require(currentPhase() == Phase.Reveal, "Not in reveal phase");
        bytes32 committed = commitments[msg.sender];
        require(committed != bytes32(0), "No commitment");
        require(!hasRevealed[msg.sender], "Already revealed");

        // Recompute commitment and verify
        bytes32 recomputed = keccak256(abi.encode(vote, salt, msg.sender));
        require(recomputed == committed, "Invalid reveal");

        hasRevealed[msg.sender] = true;

        // Tally
        if (vote) {
            yesCount += 1;
        } else {
            noCount += 1;
        }

        emit Revealed(msg.sender, vote);
    }

    // --------------------------------------------------------
    // Finalization / View
    // --------------------------------------------------------

    /// @notice Mark the vote as finalized after reveal phase is over.
    /// @dev Anyone can call after revealDeadline; just emits an event & locks in state.
    function finalize() external {
        require(currentPhase() == Phase.Finished, "Not finished");
        require(!finalized, "Already finalized");
        finalized = true;
        emit Finalized(yesCount, noCount);
    }

    /// @notice Helper to build the commitment off-chain.
    /// @dev Pure function for convenience/testing.
    function buildCommitment(bool vote, bytes32 salt, address voter) external pure returns (bytes32) {
        return keccak256(abi.encode(vote, salt, voter));
    }

    /// @notice Returns seconds remaining in the current phase.
    function secondsLeftInPhase() external view returns (uint256) {
        Phase p = currentPhase();
        if (p == Phase.Commit && block.timestamp <= commitDeadline) {
            return commitDeadline - block.timestamp;
        } else if (p == Phase.Reveal && block.timestamp <= revealDeadline) {
            return revealDeadline - block.timestamp;
        }
        return 0;
    }
}

