// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address immutable USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 1000 ether;

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5 * 10 ** 18);
    }

    function testOwnerIsDeployer() public view {
        console.log("fundMe.i_owner():", fundMe.i_owner());
        console.log("msg.sender:", msg.sender);
        // OLD VERSION
        // address(this) is the deployer , us delpoyed the contract test that deploy the contract tested
        // assertEq(fundMe.i_owner(), address(this));
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public view {
        // assertEq(fundMe.s_priceFeed.version(), 0);
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert(); // hey the next line should revert
        fundMe.fund();
    }

    function testFundUpdateFundedDataStructure() public {
        vm.prank(USER); // The next line will be executed by USER
        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER); // The next line will be executed by USER
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER); // The next line will be executed by USER
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOwnerCanWithdraw() public {
        vm.prank(USER); // The next line will be executed by USER (ignore vm stuffs)
        vm.expectRevert(); // The next line should revert
        fundMe.withdraw(); // <--- this one should revert
    }

    function testWithdrawWithASingleFunder() public funded {
        // 1.Arrange

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // 2.Act
        vm.txGasPrice(0); // to avoid gas price changes
        vm.prank(fundMe.getOwner());
        fundMe.withdraw(); //should we spent gas?

        // 3.Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingFundMeBalance
        );
    }

    function testWithdrawFromMultipleFunders() public funded {
        // 1.Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1; // not use 0 address because often used for other tests
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank new address
            // vm.deal new address
            // = hoax in foge cheatscode!
            // address(0) --> to generate one address, address(1) --> to generate two address ...
            // but only with the type uint160 ***
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // 2.Act
        vm.startPrank(fundMe.getOwner()); // alternativa piu leggibile a solo prank
        fundMe.withdraw();
        vm.stopPrank();

        // 3.Assert
        assert(address(fundMe).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
    }

    function testWithdrawFromMultipleFundersCheaper() public funded {
        // 1.Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1; // not use 0 address because often used for other tests
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank new address
            // vm.deal new address
            // = hoax in foge cheatscode!
            // address(0) --> to generate one address, address(1) --> to generate two address ...
            // but only with the type uint160 ***
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // 2.Act
        vm.startPrank(fundMe.getOwner()); // alternativa piu leggibile a solo prank
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        // 3.Assert
        assert(address(fundMe).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
    }
}
