// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

interface IDCAExecutor {
    struct DCAPlan {
        address tokenIn;
        address tokenOut;
        address recipient;
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
        uint256 indexed planId,
        address indexed tokenIn,
        address tokenOut,
        address recipient
    );

    event RecipientUpdated(
        address indexed user,
        uint256 indexed planId,
        address recipient
    );

    event PlanCancelled(address indexed user, uint256 indexed planId);

    event DCAPlanExecuted(
        address indexed user,
        uint256 indexed planId,
        address indexed tokenIn,
        address tokenOut,
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
        address _recipient
    ) external;
    function updateRecipient(uint256 _planId, address _recipient) external;
    function executeDCAPlan(
        address _user,
        uint256 _planId,
        uint256 _amountIn,
        uint24 _poolFee
    ) external returns (uint256 amountOut);
    function withdrawFees(
        address _token,
        address _to,
        uint256 _amount
    ) external;
    function cancelPlan(uint256 _planId) external;
    function checkApproval(
        address _token,
        address _owner
    ) external view returns (uint256);
    function getAllUserPlans(
        address _user
    ) external view returns (DCAPlan[] memory);
}
