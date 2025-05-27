// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "./Interfaces/ISwapRouter.sol";
import "./Interfaces/IDCAExecutor.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DCAExecutor is IDCAExecutor, Ownable {
    address public swapRouter;
    uint256 public feePercent; // in basis points (1% = 100)
    mapping(address => bool) public admins;

    mapping(address => DCAPlan) public plans;

    modifier onlyAdmin() {
        require(admins[msg.sender], "Not authorized");
        _;
    }

    constructor(address _swapRouter, uint256 _feePercent) Ownable(msg.sender) {
        swapRouter = _swapRouter;
        require(_feePercent <= 1000, "Fee too high"); // max 10%
        feePercent = _feePercent;
        admins[msg.sender] = true;
    }

    function createPlan(
        address _tokenIn,
        address _tokenOut,
        address _recipient,
        uint256 _duration
    ) external override {
        require(_tokenIn != _tokenOut, "TokenIn == TokenOut?? bruh");
        require(_duration > 0, "Duration must be > 0");
        require(_recipient != address(0), "Invalid recipient");

        plans[msg.sender] = DCAPlan({
            tokenIn: _tokenIn,
            tokenOut: _tokenOut,
            recipient: _recipient,
            lastExecution: 0,
            duration: _duration,
            active: true
        });

        emit PlanCreated(
            msg.sender,
            _tokenIn,
            _tokenOut,
            _recipient,
            _duration
        );
    }

    function updatePlan(
        address _recipient,
        uint256 _duration
    ) external override {
        DCAPlan storage plan = plans[msg.sender];
        require(plan.active, "No active plan");
        require(_duration > 0, "Duration must be > 0");
        require(_recipient != address(0), "Invalid recipient");

        plan.recipient = _recipient;
        plan.duration = _duration;

        emit PlanUpdated(msg.sender, _recipient, _duration);
    }

    function executeDCAPlan(
        address _user,
        uint256 _amountIn,
        uint24 _poolFee
    ) external override onlyAdmin {
        DCAPlan storage plan = plans[_user];
        require(plan.active, "Plan inactive");
        require(
            block.timestamp >= plan.lastExecution + plan.duration,
            "Not yet"
        );

        // Calculate fee amount
        uint256 feeAmount = (_amountIn * feePercent) / 10000;
        uint256 swapAmount = _amountIn - feeAmount;

        // Transfer tokens from user
        IERC20(plan.tokenIn).transferFrom(_user, address(this), _amountIn);

        // Approve router to spend tokens
        IERC20(plan.tokenIn).approve(swapRouter, swapAmount);

        // Execute swap
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: plan.tokenIn,
                tokenOut: plan.tokenOut,
                fee: _poolFee,
                recipient: plan.recipient,
                amountIn: swapAmount,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        uint256 amountOut = ISwapRouter(swapRouter).exactInputSingle(params);
        plan.lastExecution = block.timestamp;

        emit DCAPlanExecuted(
            _user,
            plan.tokenIn,
            plan.tokenOut,
            swapAmount,
            amountOut,
            feeAmount
        );
    }

    function cancelPlan() external override {
        DCAPlan storage plan = plans[msg.sender];
        require(plan.active, "No active plan");

        plan.active = false;

        emit PlanCancelled(msg.sender);
    }

    function updateRouter(address _swapRouter) external override onlyOwner {
        swapRouter = _swapRouter;
    }

    function updateFeePercent(
        uint256 _newFeePercent
    ) external override onlyOwner {
        require(_newFeePercent <= 1000, "Fee too high"); // max 10%
        uint256 oldFeePercent = feePercent;
        feePercent = _newFeePercent;
        emit FeePercentUpdated(oldFeePercent, _newFeePercent);
    }

    function withdrawFees(
        address _token,
        address _to
    ) external override onlyOwner {
        uint256 amount = IERC20(_token).balanceOf(address(this));
        require(amount > 0, "No fees to withdraw");
        IERC20(_token).transfer(_to, amount);
        emit FeeWithdrawn(_token, _to, amount);
    }

    function checkApproval(
        address _token,
        address _owner
    ) external view override returns (uint256) {
        uint256 allowance = IERC20(_token).allowance(_owner, address(this));
        return allowance;
    }

    function setAdmin(address _newAdmin, bool _isAdmin) external onlyOwner {
        require(_newAdmin != address(0), "Invalid admin address");
        admins[_newAdmin] = _isAdmin;
        emit AdminUpdated(_newAdmin);
    }
}
