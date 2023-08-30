// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LendingPlatform is Ownable {
    IERC20 public token;

    uint256 public maxBorrowAmount;
    uint256 public interestRate; // Annual interest rate (in basis points)
    uint256 public loanDuration; // Loan duration in seconds

    struct Loan {
        uint256 principal;
        uint256 interest;
        uint256 createTime;
        uint256 repayTime;
        address borrower;
        bool active;
    }

    mapping(address => uint256) public borrowerTotalDebt;
    mapping(address => Loan[]) public borrowerLoans;
    mapping(address => uint256) public lenderEarnings;

    event LoanCreated(
        address indexed borrower,
        address indexed lender,
        uint256 principal,
        uint256 interest
    );

    event LoanRepaid(
        address indexed borrower,
        address indexed lender,
        uint256 principal,
        uint256 interest
    );

    constructor(
        address _tokenAddress,
        uint256 _maxBorrowAmount,
        uint256 _interestRate,
        uint256 _loanDuration
    ) {
        token = IERC20(_tokenAddress);
        maxBorrowAmount = _maxBorrowAmount;
        interestRate = _interestRate;
        loanDuration = _loanDuration;
    }

    function borrowTokens(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        require(_amount <= maxBorrowAmount, "Amount exceeds maximum borrow limit");

        uint256 interest = (_amount * interestRate * loanDuration) / (365 days * 10000);
        uint256 repayTime = block.timestamp + loanDuration;

        borrowerTotalDebt[msg.sender] += _amount + interest;

        Loan memory newLoan = Loan({
            principal: _amount,
            interest: interest,
            createTime: block.timestamp,
            repayTime: repayTime,
            borrower: msg.sender,
            active: true
        });

        borrowerLoans[msg.sender].push(newLoan);

        emit LoanCreated(msg.sender, address(0), _amount, interest);
    }

    function repayLoan(uint256 _loanIndex) external {
        require(_loanIndex < borrowerLoans[msg.sender].length, "Invalid loan index");

        Loan storage loan = borrowerLoans[msg.sender][_loanIndex];
        require(loan.active, "Loan is not active");
        require(block.timestamp < loan.repayTime, "Loan is overdue");

        uint256 repayAmount = loan.principal + loan.interest;

        token.transferFrom(msg.sender, address(this), repayAmount);

        borrowerTotalDebt[msg.sender] -= repayAmount;
        lenderEarnings[owner()] += loan.interest;

        loan.active = false;

        emit LoanRepaid(msg.sender, owner(), loan.principal, loan.interest);
    }

    // Admin function to withdraw lender earnings
    function withdrawEarnings() external onlyOwner {
        require(lenderEarnings[msg.sender] > 0, "No earnings to withdraw");

        uint256 earnings = lenderEarnings[msg.sender];
        lenderEarnings[msg.sender] = 0;

        token.transfer(msg.sender, earnings);
    }
}
