// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {Test, console} from "forge-std/Test.sol";
import {DCAForwarder} from "../src/DCA.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DCAExecutorTest is Test {
    DCAForwarder public dcaForwarder;
    address OWNER = vm.envAddress("OWNER_ADDRESS");
    address ADMIN = vm.envAddress("ADMIN_ADDRESS");
    address USER = vm.envAddress("USER_ADDRESS");
    address USER2 = 0xc9B06E8122f0c51eB69EA713E27dA922CA7c458E;
    address REFERRER = 0xE42c136730A9CfeFb5514D4d3D06EB27BAAf3f08;
    address USDC = vm.envAddress("USDC_ADDRESS");
    address WETH = vm.envAddress("WETH_ADDRESS");
    address ROUTER = vm.envAddress("ROUTER_ADDRESS");

    IERC20 public usdc;
    IERC20 public dest;

    // Token addresses
    address public toToken = 0xcbADA732173e39521CDBE8bf59a6Dc85A9fc7b8c;
    uint256 public amount = 20000000; // 20 USDC (6 decimals)

    // 1inch swap data
    bytes public oneInchData =
        hex"07ed23790000000000000000000000006ea77f83ec8693666866ece250411c974ab962a8000000000000000000000000833589fcd6edb6e08f4c7c32d4f71b54bda02913000000000000000000000000cbada732173e39521cdbe8bf59a6dc85a9fc7b8c0000000000000000000000006ea77f83ec8693666866ece250411c974ab962a80000000000000000000000007c752f3d7964397ee018c8d9b4cec5e155d6130a0000000000000000000000000000000000000000000000000000000000030d40000000000000000000000000000000000000000000000000000000000003d1d10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000012000000000000000000000000000000000000000000000000000000000000001310000000000000000000000000000000000000000000001130000e500008200a07225b0d0833589fcd6edb6e08f4c7c32d4f71b54bda02913e42c136730a9cfefb5514d4d3d06eb27baaf3f08000000000000000000000000000000000000000000000000000000000000177190cbe4bdd538d6e9b379bff5fe72c3d67a521de5000000000000000000000000000000000000000000000000000000000000025702a0000000000000000000000000000000000000000000000000000000000003d1d1ee63c1e581395340b92672ba1c7b73bbd24c2573ad60419619833589fcd6edb6e08f4c7c32d4f71b54bda02913111111125421ca6dc452d289314280a0f8842a650020d6bdbf78cbada732173e39521cdbe8bf59a6dc85a9fc7b8c111111125421ca6dc452d289314280a0f8842a6500000000000000000000000000000096605042";

    function setUp() public {
        dcaForwarder = DCAForwarder(
            payable(0x7C752f3D7964397ee018C8D9B4cEc5E155D6130a)
        );

        usdc = IERC20(USDC);
        dest = IERC20(toToken);

        vm.startPrank(USER);
        // USER creates the plan
        dcaForwarder.createPlan(toToken, USER);

        usdc.approve(address(dcaForwarder), amount);

        vm.stopPrank();

        vm.startPrank(USER2);
        // USER creates the plan
        dcaForwarder.createPlan(toToken, USER2);

        usdc.approve(address(dcaForwarder), amount);

        vm.stopPrank();
    }

    function test_executeSwap() public {
        uint256 balanceBefore = dest.balanceOf(USER);
        uint256 balanceBeforeRef = usdc.balanceOf(REFERRER);
        console.log("balanceBefore", balanceBefore);
        console.log("balanceBeforeRef", balanceBeforeRef);

        vm.prank(OWNER);
        dcaForwarder.executeSwap(USER, toToken, USER, 2000000, oneInchData);
        vm.stopPrank();

        uint256 balanceAfter = dest.balanceOf(USER);
        uint256 balanceAfterRef = usdc.balanceOf(REFERRER);
        assertGt(balanceAfter, balanceBefore);
        assertGt(balanceAfterRef, balanceBeforeRef);
        console.log("balanceAfter", balanceAfter);
        console.log("balanceAfterRef", balanceAfterRef);
    }
    function test_executeSwapWithFee() public {
        uint256 balanceBefore = dest.balanceOf(USER);
        uint256 balanceBeforeRef = usdc.balanceOf(REFERRER);
        console.log("balanceBefore", balanceBefore);
        console.log("balanceBeforeRef", balanceBeforeRef);

        vm.prank(OWNER);
        dcaForwarder.executeSwap(USER, toToken, USER, 2000000, oneInchData);
        vm.stopPrank();

        uint256 balanceAfter = dest.balanceOf(USER);
        uint256 balanceAfterRef = usdc.balanceOf(REFERRER);
        assertGt(balanceAfter, balanceBefore);
        assertGt(balanceAfterRef, balanceBeforeRef);
        console.log("balanceAfter", balanceAfter);
        console.log("balanceAfterRef", balanceAfterRef);
    }

    // function test_executeNativeSwap() public {
    //     vm.prank(OWNER);
    //     uint256 balanceBefore = address(USER).balance;
    //     console.log("eth balanceBefore", balanceBefore);
    //     dcaForwarder.executeNativeSwap(
    //         USER,
    //         toToken,
    //         USER,
    //         amount,
    //         oneInchData
    //     );
    //     uint256 balanceAfter = address(USER).balance;
    //     console.log("eth balanceAfter", balanceAfter);
    //     assertGt(balanceAfter, balanceBefore);
    //     vm.stopPrank();
    // }
}
