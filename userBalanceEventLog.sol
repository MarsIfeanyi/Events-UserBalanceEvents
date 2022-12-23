// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

// Custom errors
error NotaDepositorAlready();
error AmountTooSmall();
error InsufficientBalance();

contract UserBalanceEventLog {
    address payable public owner;

    uint private constant FEE = 10;

    struct UserDetail {
        string userName;
        uint256 userAge;
    }

    // Mapping of address to Struct
    mapping(address => UserDetail) public usersDetail;

    //mapping of address to uint256
    mapping(address => uint256) public balances;

    constructor() {
        owner = payable(msg.sender);
    }

    // Deposit Event
    event FundsDeposited(address user, uint256 amount);

    // functions that saves the amount a user is depositing into a mapping
    function deposit(uint256 amount) public {
        balances[msg.sender] += amount;

        // Emit deposit event
        emit FundsDeposited(msg.sender, amount);
    }

    // function that searches for user balance inside the mapping and returns the balance of who calls the contract.
    function checkBalance() public view returns (uint) {
        return balances[msg.sender];
    }

    // Profile update Event
    event ProfileUpdated(address user);

    // function that saves the details of the user calling the smart contract into defined struct
    function setUserDetails(string calldata name, uint256 age) public {
        usersDetail[msg.sender] = UserDetail({userName: name, userAge: age});

        // emit event
        emit ProfileUpdated(msg.sender);
    }

    // function retrieves and returns the details saved for the user calling the contract.
    function getUserDetail() public view returns (string memory, uint256) {
        UserDetail memory userDetail = usersDetail[msg.sender];
        return (userDetail.userName, userDetail.userAge);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only Owner Allowed");
        _;
    }

    // function that allows only the owner to withdraw funds
    function withdrawFunds() public payable onlyOwner {
        // get the amount of Ether stored in this contract
        uint amount = address(this).balance;

        require(balances[msg.sender] >= amount, "Insufficient balance");

        // Owner can receive Ether since the address of owner is payable
        (bool success, ) = owner.call{value: amount}("");
        require(success, "Funds Withdrawal Failed");

        balances[msg.sender] -= amount;
    }

    modifier onlyDepositor() {
        if (balances[msg.sender] <= 0) {
            revert NotaDepositorAlready();
        }
        _;
    }
    modifier validateAmount(uint256 _amount) {
        if (_amount <= FEE) {
            revert AmountTooSmall();
        }
        _;
    }

    // function that allows only users that have deposited, to increase their balance on the mapping
    function addFund(
        uint256 _amount
    ) public onlyDepositor validateAmount(_amount) {
        balances[msg.sender] += _amount;
    }
}
