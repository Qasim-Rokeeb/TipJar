// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title TipJar
 * @dev A smart contract that accepts tips and maintains a contributor leaderboard
 * @author Your Name
 */
contract TipJar {
    // State variables
    address public owner;
    uint256 public totalTips;
    uint256 public totalContributors;
    
    // Struct to store contributor information
    struct Contributor {
        address addr;
        uint256 totalTipped;
        uint256 tipCount;
        string name;
        bool exists;
    }
    
    // Mappings
    mapping(address => Contributor) public contributors;
    address[] public contributorAddresses;
    
    // Events
    event TipReceived(
        address indexed tipper,
        uint256 amount,
        string message,
        uint256 timestamp
    );
    
    event ContributorRegistered(
        address indexed contributor,
        string name,
        uint256 timestamp
    );
    
    event Withdrawal(
        address indexed owner,
        uint256 amount,
        uint256 timestamp
    );

    // Custom errors
    error InsufficientTipAmount();
    error WithdrawalFailed();
    error OnlyOwner();
    error ContributorAlreadyExists();
    
    // Modifiers
    modifier onlyOwner() {
        if (msg.sender != owner) revert OnlyOwner();
        _;
    }
    
    modifier validTipAmount() {
        if (msg.value == 0) revert InsufficientTipAmount();
        _;
    }
    
    // Constructor
    constructor() {
        owner = msg.sender;
    }
    
    /**
     * @dev Send a tip with an optional message
     * @param _message Optional message from the tipper
     * @param _name Optional name for the contributor (for first-time tippers)
     */
    function sendTip(string calldata _message, string calldata _name) 
        external 
        payable 
        validTipAmount 
    {
        // If contributor doesn't exist, create them
        if (!contributors[msg.sender].exists) {
            contributors[msg.sender] = Contributor({
                addr: msg.sender,
                totalTipped: 0,
                tipCount: 0,
                name: bytes(_name).length > 0 ? _name : "Anonymous",
                exists: true
            });
            contributorAddresses.push(msg.sender);
            totalContributors++;
            
            emit ContributorRegistered(msg.sender, contributors[msg.sender].name, block.timestamp);
        }
        
        // Update contributor stats
        contributors[msg.sender].totalTipped += msg.value;
        contributors[msg.sender].tipCount++;
        
        // Update global stats
        totalTips += msg.value;
        
        // Emit event
        emit TipReceived(msg.sender, msg.value, _message, block.timestamp);
    }
    
    /**
     * @dev Get top contributors (leaderboard)
     * @param _limit Maximum number of contributors to return
     * @return Top contributors sorted by total tips
     */
    function getTopContributors(uint256 _limit) 
        external 
        view 
        returns (Contributor[] memory) 
    {
        uint256 limit = _limit > contributorAddresses.length ? contributorAddresses.length : _limit;
        Contributor[] memory topContributors = new Contributor[](limit);
        
        // Create a copy of contributors for sorting
        Contributor[] memory allContributors = new Contributor[](contributorAddresses.length);
        for (uint256 i = 0; i < contributorAddresses.length; i++) {
            allContributors[i] = contributors[contributorAddresses[i]];
        }
        
        // Simple bubble sort (sufficient for small arrays)
        for (uint256 i = 0; i < allContributors.length - 1; i++) {
            for (uint256 j = 0; j < allContributors.length - i - 1; j++) {
                if (allContributors[j].totalTipped < allContributors[j + 1].totalTipped) {
                    Contributor memory temp = allContributors[j];
                    allContributors[j] = allContributors[j + 1];
                    allContributors[j + 1] = temp;
                }
            }
        }
        
        // Return top contributors
        for (uint256 i = 0; i < limit; i++) {
            topContributors[i] = allContributors[i];
        }
        
        return topContributors;
    }
    
    /**
     * @dev Get contributor information by address
     * @param _contributor Address of the contributor
     * @return Contributor information
     */
    function getContributor(address _contributor) 
        external 
        view 
        returns (Contributor memory) 
    {
        return contributors[_contributor];
    }
    
    /**
     * @dev Get total number of contributors
     * @return Total number of unique contributors
     */
    function getTotalContributors() external view returns (uint256) {
        return totalContributors;
    }
    
    /**
     * @dev Get contract balance
     * @return Current contract balance in wei
     */
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
    
    /**
     * @dev Withdraw all tips (only owner)
     */
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        
        (bool success, ) = payable(owner).call{value: balance}("");
        if (!success) revert WithdrawalFailed();
        
        emit Withdrawal(owner, balance, block.timestamp);
    }
    
    /**
     * @dev Withdraw specific amount (only owner)
     * @param _amount Amount to withdraw in wei
     */
    function withdrawAmount(uint256 _amount) external onlyOwner {
        require(_amount <= address(this).balance, "Insufficient contract balance");
        
        (bool success, ) = payable(owner).call{value: _amount}("");
        if (!success) revert WithdrawalFailed();
        
        emit Withdrawal(owner, _amount, block.timestamp);
    }
    
    /**
     * @dev Update contributor name
     * @param _newName New name for the contributor
     */
    function updateName(string calldata _newName) external {
        require(contributors[msg.sender].exists, "Contributor does not exist");
        contributors[msg.sender].name = _newName;
    }
    
    /**
     * @dev Transfer ownership
     * @param _newOwner Address of the new owner
     */
    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "Invalid address");
        owner = _newOwner;
    }
    
    // Fallback function to accept tips without message
    receive() external payable {
        if (msg.value > 0) {
            this.sendTip("", "");
        }
    }
}