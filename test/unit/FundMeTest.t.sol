// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18; 

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest  is Test{
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether; // 100000000000000000 
    uint256 constant STARTING_BALANCE = 10 ether;  
    uint256 constant GAS_PRICE = 1;

    modifier funded(){
        vm.prank(USER); //is says that the next Tx will be send by the user
        fundMe.fund{value: SEND_VALUE}();
        _;
    }
    
    function setUp() external {
        DeployFundMe deployFundMe =  new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinDollarIs5() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public{
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testVersion() public {
        uint256 version =  fundMe.getVersion();
        assertEq(version, 4);
    }
    
    function testFundFailsWithoutEnoughtEth() public{
        vm.expectRevert(); //the next line should revert
        //assert(Tx fails/reverts)
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public funded{
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public funded{
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded{
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    

    function testWithdrawWithSingleFunder() public funded{
        //arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance; 
        uint256 startingFundMeBalance = address(fundMe).balance;

        //act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        //assert 
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance+startingOwnerBalance, endingOwnerBalance);
    }

    function testWithdrawFromMultipleFunders() public funded{
        //arrange
        uint160 numberOfFunders =10; //uint160 should be used instead of uint256 for generating address from numbers
        uint160 startingFunderIndex = 1; //not zero bcz sometimes 0 address reverts bcz there are often sanity checks while testing
        for(uint160 i= startingFunderIndex;i<numberOfFunders;i++){
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        
        uint256 startingOwnerBalance = fundMe.getOwner().balance; 
        uint256 startingFundMeBalance = address(fundMe).balance;

        //act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();
        
        //assert 
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance+startingOwnerBalance, endingOwnerBalance);
    }

    function testWithdrawFromMultipleFundersCheaper() public funded{
        //arrange
        uint160 numberOfFunders =10; //uint160 should be used instead of uint256 for generating address from numbers
        uint160 startingFunderIndex = 1; //not zero bcz sometimes 0 address reverts bcz there are often sanity checks while testing
        for(uint160 i= startingFunderIndex;i<numberOfFunders;i++){
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        
        uint256 startingOwnerBalance = fundMe.getOwner().balance; 
        uint256 startingFundMeBalance = address(fundMe).balance;

        //act
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();
        
        //assert 
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance+startingOwnerBalance, endingOwnerBalance);
    }
}