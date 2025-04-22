//SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

contract USDT {
    string public name = "Tether USD";
    string public symbol = "USDT";
    uint8 public decimal = 18;
    uint256 public totalSupply;
    uint256 public constant MAX_SUPPLY = 10_000_000_000 * 10 ** 18;
    
    bool transferFromPause = false;
    address public owner;
    
    mapping (address => uint256) balancesOf;
    mapping (address => mapping(address => uint256)) allowances;
    
   
    
    constructor () {
        owner = msg.sender;
        _mint(msg.sender, MAX_SUPPLY);
    }
    
    modifier onlyOwner(){
        require(owner == msg.sender, "Only owner can perform operation");
        _;
    }
    
    event minted (address indexed receiver, uint256 amount);
    event tokenTransferred (address indexed sender, address indexed receiver, uint256 amount);
    event approval (address indexed by, address indexed to, uint256 amount);
    event transferFromPaused (address indexed by);
    event transferFromUnpaused (address indexed by);
    
    function _mint (address to, uint256 amount) internal {
        require (totalSupply + amount <= MAX_SUPPLY,"Exceeds max supply");
        balancesOf[to] += amount;
        totalSupply += amount;
        emit minted (to, amount);
        emit tokenTransferred (address(0), to, amount);
    }
    
    function mint (address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
    
    function approve (address spender, uint256 amount) external returns (bool) {
        require (balancesOf[msg.sender] >= amount, "Insufficient balance");
        allowances[msg.sender][spender] += amount;
        emit approval(msg.sender, spender, amount);
        return true;
    }
    
    function transfer(address receiver, uint256 amount) external returns (bool) {
        require(balancesOf[msg.sender] >= amount, "Insufficient Balance");
        balancesOf[msg.sender] -= amount;
        balancesOf[receiver] += amount;
        emit tokenTransferred(msg.sender, receiver, amount);
        return true;
    }
    
    function pauseTransferFrom() external onlyOwner {
        require (transferFromPause == false, "Contract is already paused");
        transferFromPause = true;
        emit transferFromPaused(msg.sender);
    }
    
    function unpauseTransferFrom() external onlyOwner{
        require (transferFromPause == true, "Contract is already unpaused");
        transferFromPause == false;
        emit transferFromUnpaused (msg.sender);
    }
    
    function transferFrom (address sender, address receiver, uint256 amount) external returns (bool){
        require(transferFromPause == false, "Try again Later");
        require(balancesOf[sender] >= amount, "Insufficient balance");
        require(allowances[sender][msg.sender] >= amount, "Allowance exceeded");
        balancesOf[sender] -= amount;
        allowances[sender][msg.sender] -= amount;
        balancesOf[receiver] += amount;
        emit tokenTransferred (sender, receiver, amount);
        return true;
        
}


}
