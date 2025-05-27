// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

interface IDCAExecutor {
    struct DCAPlan {
        address tokenIn;
        address tokenOut;
        address recipient;
        uint256 lastExecution;
        uint256 duration;
        bool active;
    }

    event DCAExecuted(
        address indexed tokenIn,
        address indexed tokenOut,
        uint256 amountIn,
        uint256 amountOut,
        uint24 poolFee,
        uint256 timestamp
    );

    event PlanCreated(
        address indexed user,
        address indexed tokenIn,
        address indexed tokenOut,
        address recipient,
        uint256 duration
    );

    event PlanUpdated(
        address indexed user,
        address recipient,
        uint256 duration
    );

    event PlanCancelled(address indexed user);

    event DCAPlanExecuted(
        address indexed user,
        address indexed tokenIn,
        address indexed tokenOut,
        uint256 amountIn,
        uint256 amountOut,
        uint256 feeAmount
    );

    event FeeWithdrawn(
        address indexed token,
        address indexed to,
        uint256 amount
    );

    event FeePercentUpdated(uint256 oldFeePercent, uint256 newFeePercent);

    event AdminUpdated(address indexed newAdmin);

    function updateRouter(address _swapRouter) external;
    function updateFeePercent(uint256 _newFeePercent) external;
    function createPlan(
        address _tokenIn,
        address _tokenOut,
        address _recipient,
        uint256 _duration
    ) external;
    function updatePlan(address _recipient, uint256 _duration) external;
    function executeDCAPlan(
        address _user,
        uint256 _amountIn,
        uint24 _poolFee
    ) external;
    function withdrawFees(address _token, address _to) external;
    function cancelPlan() external;
    function checkApproval(
        address _token,
        address _owner
    ) external view returns (uint256);
}
