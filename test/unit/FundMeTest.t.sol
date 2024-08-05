// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user"); // 测试用户地址
    uint256 constant SEND_VALUE = 0.1 ether; // 发送金额
    uint256 constant STARTING_BALANCE = 10 ether; // 初始余额

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run(); // 部署 FundMe 合约
        vm.deal(USER, STARTING_BALANCE); // 为用户分配初始余额
    }

    // function testMinimumDollarIsFive() public {
    //     assertEq(fundMe.getOwner(), msg.sender); // 检查合约所有者是否为部署者
    // }

    // function testPriceFeedVersionIsAccurate() public {
    //     uint256 version = fundMe.getVersion();
    //     assertEq(version, 4); // 检查版本是否为 4
    // }

    // function testOwnerIsMsgSender() public {
    //     assertEq(fundMe.getOwner(), msg.sender);
    // }

    //检查提供不足的以太币时交易是否失败。
    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert(); // 预期交易失败

        fundMe.fund();
    }

    //检查提供资金后数据结构是否更新。
    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); // 将下一个交易的调用者设为 USER
        fundMe.fund{value: SEND_VALUE}(); // 用户提供资金
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    //检查提供资金后资助者是否被添加到数组中。
    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER); // 将下一个交易的调用者设为 USER
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    //检查只有合约所有者可以提取资金。
    function testOnlyOwenerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    //测试单一资助者的提取资金功能。
    function testWithDrawWithASingleFunder() public funded {
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    //测试多个资助者的提取资金功能。
    function testWithdrawFromMultipleFunders() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
    }

    //测试多个资助者的优化提取资金功能。
    function testWithdrawFromMultipleFundersCheaper() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
    }
}
