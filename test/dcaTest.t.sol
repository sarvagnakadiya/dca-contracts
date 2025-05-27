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
        dcaExecutor.createPlan(usdc, btcb, user, 100);

        (
            address tokenIn,
            address tokenOut,
            address recipient,
            uint256 lastExecution,
            uint256 duration,
            bool active
        ) = dcaExecutor.plans(user);
        assertEq(tokenIn, usdc);
        assertEq(tokenOut, btcb);
        assertEq(recipient, user);
        assertEq(lastExecution, 0);
        assertEq(duration, 100);
        assertTrue(active);

        vm.stopPrank();
    }

    // function testFail_CreatePlanWithSameTokens() public {
    //     vm.startPrank(user);
    //     dcaExecutor.createPlan(usdc, usdc, user, 100);
    //     vm.stopPrank();
    // }

    function test_UpdatePlan() public {
        test_CreatePlan();

        vm.startPrank(user);
        address newRecipient = address(0x123);
        uint256 newDuration = 200;

        dcaExecutor.updatePlan(newRecipient, newDuration);

        (, , address recipient, , uint256 duration, ) = dcaExecutor.plans(user);
        assertEq(recipient, newRecipient);
        assertEq(duration, newDuration);

        vm.stopPrank();
    }

    // function testFail_UpdatePlanWithoutActivePlan() public {
    //     vm.startPrank(user);
    //     dcaExecutor.updatePlan(address(0x123), 200);
    //     vm.stopPrank();
    // }

    // function test_CancelPlan() public {
    //     test_CreatePlan();

    //     vm.startPrank(user);
    //     dcaExecutor.cancelPlan();

    //     (, , , , , bool active) = dcaExecutor.plans(user);
    //     assertFalse(active);

    //     vm.stopPrank();
    // }

    // function testFail_CancelPlanWithoutActivePlan() public {
    //     vm.startPrank(user);
    //     dcaExecutor.cancelPlan();
    //     vm.stopPrank();
    // }

    // function test_UpdateRouter() public {
    //     vm.startPrank(owner);
    //     address newRouter = address(0x456);
    //     dcaExecutor.updateRouter(newRouter);
    //     assertEq(dcaExecutor.swapRouter(), newRouter);
    //     vm.stopPrank();
    // }

    function test_ExecuteDCAPlan() public {
        test_CreatePlan();

        vm.startPrank(user);
        IERC20(usdc).approve(address(dcaExecutor), amountIn);
        vm.stopPrank();

        vm.startPrank(owner);
        dcaExecutor.executeDCAPlan(user, 2000000, 10000);

        (, , , uint256 lastExecution, , ) = dcaExecutor.plans(user);
        assertEq(lastExecution, block.timestamp);

        vm.stopPrank();
    }

    // function testFail_ExecuteDCAPlanInactive() public {
    //     test_CreatePlan();
    //     test_CancelPlan();

    //     vm.startPrank(owner);
    //     dcaExecutor.executeDCAPlan(user, amountIn, 3000);
    //     vm.stopPrank();
    // }

    // function testFail_ExecuteDCAPlanTooEarly() public {
    //     test_CreatePlan();

    //     vm.startPrank(owner);
    //     dcaExecutor.executeDCAPlan(user, amountIn, 3000);
    //     // Try to execute again immediately
    //     dcaExecutor.executeDCAPlan(user, amountIn, 3000);
    //     vm.stopPrank();
    // }
}
