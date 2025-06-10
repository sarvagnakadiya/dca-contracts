// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.29;

import {Test, console} from "forge-std/Test.sol";
import {DCAExecutor} from "../src/DCAExecutor.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DCAExecutorTest is Test {
    DCAExecutor public dcaExecutor;
    address router = 0x2626664c2603336E57B271c5C0b26F421741e481;
    address user = vm.envAddress("USER1_ADDRESS");
    address owner = vm.envAddress("OWNER_ADDRESS");
    address usdc = vm.envAddress("USDC_ADDRESS");
    address btcb = vm.envAddress("BTCB_ADDRESS");
    uint256 amountIn = 15000000;
    uint256 feePercent = 100; // 1%

    function setUp() public {
        vm.startPrank(owner);
        dcaExecutor = new DCAExecutor(router, feePercent);
        vm.stopPrank();

        // Approve DCAExecutor to spend user's USDC
        vm.startPrank(user);
        IERC20(usdc).approve(address(dcaExecutor), type(uint256).max);
        vm.stopPrank();
    }

    function test_CreatePlan() public {
        vm.startPrank(user);
        dcaExecutor.createPlan(usdc, btcb, user);

        (
            address tokenIn,
            address tokenOut,
            address recipient,
            bool active
        ) = dcaExecutor.userPlans(user, 0);
        assertEq(tokenIn, usdc);
        assertEq(tokenOut, btcb);
        assertEq(recipient, user);
        assertTrue(active);

        vm.stopPrank();
    }

    function test_UpdatePlan() public {
        test_CreatePlan();

        vm.startPrank(user);
        address newRecipient = address(0x123);

        dcaExecutor.updateRecipient(0, newRecipient);

        (, , address recipient, ) = dcaExecutor.userPlans(user, 0);
        assertEq(recipient, newRecipient);

        vm.stopPrank();
    }

    function test_ExecuteDCAPlan() public {
        test_CreatePlan();

        vm.startPrank(user);
        IERC20(usdc).approve(address(dcaExecutor), amountIn);
        vm.stopPrank();

        vm.startPrank(owner);
        console.log("recipient balance", address(user).balance);
        uint256 balanceBefore = address(user).balance;

        uint256 amountOut = dcaExecutor.executeDCAPlan(user, 0, 2000000, 10000);
        uint256 balanceAfter = address(user).balance;
        console.log("amountOut", amountOut);

        console.log("User balance", IERC20(usdc).balanceOf(user));
        console.log("recipient balance", address(user).balance);
        assertEq(balanceAfter - balanceBefore, amountOut);

        vm.stopPrank();
    }

    function test_WithdrawFees() public {
        test_ExecuteDCAPlan(); // This will create and execute a plan, generating fees

        vm.startPrank(owner);
        uint256 balanceBefore = IERC20(usdc).balanceOf(owner);

        // Calculate expected fee amount (1% of 2000000 = 20000)
        uint256 expectedFee = 20000;
        dcaExecutor.withdrawFees(usdc, owner, expectedFee);

        uint256 balanceAfter = IERC20(usdc).balanceOf(owner);
        assertEq(
            balanceAfter - balanceBefore,
            expectedFee,
            "Fee withdrawal amount incorrect"
        );

        vm.stopPrank();
    }
}
