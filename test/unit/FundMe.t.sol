// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe private fundMe;
    address private USER = makeAddr("user");
    uint256 private SEND_VALUE = 0.1 ether;
    uint256 private STARTING_VALUE = 10 ether;

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();
        vm.deal(USER, STARTING_VALUE);
    }

    function testMinimumFiveDollar() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwner() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testAggregateV3InterfaceVersion() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundNotEnoughETH() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testAddressToAmountDataStructure() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        assertEq(fundMe.getAmountFundedFromAddress(USER), SEND_VALUE);
    }

    function testFundersArray() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        assertEq(fundMe.getFunderAddresFromIndex(0), USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawFromASingleFunder() public funded {
        // Arrange
        address fundMeOwner = fundMe.getOwner();
        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMeOwner.balance;

        // Act
        vm.prank(fundMeOwner);
        fundMe.withdraw();

        // Assert
        uint256 endingOwnerBalance = fundMeOwner.balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawFromMultiFunder() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunder = 1; // start from 1 because if start from 0, sometimes get reverted

        for (uint160 i = startingFunder; i < numberOfFunders; i++) {
            // hoax is similiar to:
            //  vm.prank(address);
            //  vm.deal(address, value);
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        address fundMeOwner = fundMe.getOwner();
        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMeOwner.balance;

        // Act
        vm.startPrank(fundMeOwner);
        fundMe.withdraw();
        vm.stopPrank();

        // Assert
        uint256 endingFundMeBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = fundMeOwner.balance;
        assert(endingFundMeBalance == 0);
        assert(
            endingOwnerBalance == (startingFundMeBalance + startingOwnerBalance)
        );
    }
}
