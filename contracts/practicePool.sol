// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

//create an errors

error TokennotAllowed(address token);
error  Transferfalied();
error NeedMoreThanZero();
contract Lending_Borrowing  is ReentrancyGuard, Ownable{
   IERC20 public token;

//   create  an outlet structure of lending platform
 /*
  functions: 
  1. supply the  token into pool
  2. borrow the loan
  3. repay the loan
  4. withdraw funds or token that supplied by lender
  additional func.
     check the balance of lender and borrower
   5. liquidation
   6. collatral value that putted by borrower
   7. health factor if you want to add.

   modifier ==> 1.isAllowedtoken  2. morethanzero

   set events ==> borrow, deposite, withdraw, repay , liquidate


  */

  mapping(address => address) public s_TokenToPrceFeed;
  
  address[] public s_allowedTokens;

  // account => token => amount

  mapping(address => mapping(address => uint256)) public  s_accountToTokenDeposits;
    // Account -> Token -> Amount
  mapping(address => mapping(address => uint256)) public s_accountToTokenBorrows;

  //liquidation reward is 5%

  uint256 public constant LIQUIDATION_REWARD = 5;
  // At 80% Loan to Value Ratio, the loan can be liquidated
  uint256 public constant LIQUIDATION_THRESHOLD = 80;
  uint256 public constant MIN_HEALH_FACTOR = 1e18;

  
}