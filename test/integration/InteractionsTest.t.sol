// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";
import {FundMe} from "../../src/FundMe.sol";
import {Test, console} from "forge-std/Test.sol";

contract InteractionsTest is Test {
    FundMe public fundMe; //FundMe 合约实例
    DeployFundMe deployFundMe; //DeployFundMe 合约实例，用于部署 FundMe 合约。

    uint256 public constant SEND_VALUE = 0.1 ether;
    uint256 public constant STARTING_USER_BALANCE = 10 ether;

    address alice = makeAddr("alice"); //模拟的用户地址。

    //测试的初始化函数。在每个测试函数运行之前调用。
    function setUp() external {
        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(alice, STARTING_USER_BALANCE); //将初始金额分配给 alice 地址。
    }

    //测试用户是否可以通过 FundMe 合约进行资金交互。
    function testUserCanFundInteractions() public {
        uint256 preUserBalance = address(alice).balance;
        uint256 preOwnerBalance = address(fundMe.getOwner()).balance;

        // 模拟 alice 作为交易发送者
        vm.prank(alice);
        fundMe.fund{value: SEND_VALUE}();

        //提取资金
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        //记录资金交互后的余额
        uint256 afterUserBalance = address(alice).balance;
        uint256 afterOwnerBalance = address(fundMe.getOwner()).balance;

        assert(address(fundMe).balance == 0);
        assertEq(afterUserBalance + SEND_VALUE, preUserBalance);
        assertEq(preOwnerBalance + SEND_VALUE, afterOwnerBalance);
    }
}
