// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "./Interfaces/ISwapRouter.sol";
import "./Interfaces/IDCAExecutor.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./Interfaces/IWETH9.sol";

contract DCAExecutor is IDCAExecutor, Ownable, ReentrancyGuard {
    address public swapRouter;
    uint256 public feePercent; // in basis points (1% = 100)
    mapping(address => bool) public admins;
    address public constant WETH = 0x4200000000000000000000000000000000000006;

    // Changed from single plan to array of plans
    mapping(address => DCAPlan[]) public userPlans;
    // Mapping to track plan IDs for each user
    mapping(address => uint256) public userPlanCount;

    // Add receive function to accept ETH
    receive() external payable {
        require(msg.sender == WETH, "Only WETH can send ETH");
    }

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
        address _recipient
    ) external override {
        require(_tokenIn != _tokenOut, "TokenIn == TokenOut?? bruh");
        require(_recipient != address(0), "Invalid recipient");

        uint256 planId = userPlanCount[msg.sender];
        userPlans[msg.sender].push(
            DCAPlan({
                tokenIn: _tokenIn,
                tokenOut: _tokenOut,
                recipient: _recipient,
                active: true
            })
        );
        userPlanCount[msg.sender]++;

        emit PlanCreated(msg.sender, planId, _tokenIn, _tokenOut, _recipient);
    }

    function updateRecipient(
        uint256 _planId,
        address _recipient
    ) external override {
        require(_planId < userPlanCount[msg.sender], "Invalid plan ID");
        DCAPlan storage plan = userPlans[msg.sender][_planId];
        require(plan.active, "No active plan");
        require(_recipient != address(0), "Invalid recipient");

        plan.recipient = _recipient;

        emit RecipientUpdated(msg.sender, _planId, _recipient);
    }

    function executeDCAPlan(
        address _user,
        uint256 _planId,
        uint256 _amountIn,
        uint24 _poolFee
    ) external override onlyAdmin nonReentrant returns (uint256 amountOut) {
        require(_planId < userPlanCount[_user], "Invalid plan ID");
        DCAPlan storage plan = userPlans[_user][_planId];
        require(plan.active, "Plan inactive");

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
                recipient: plan.tokenOut == WETH
                    ? address(this)
                    : plan.recipient,
                amountIn: swapAmount,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        amountOut = ISwapRouter(swapRouter).exactInputSingle(params);

        // If output token is WETH, unwrap it and send ETH to recipient
        if (plan.tokenOut == WETH) {
            IWETH9(WETH).withdraw(amountOut);
            (bool success, ) = plan.recipient.call{value: amountOut}("");
            require(success, "ETH transfer failed");
        }

        emit DCAPlanExecuted(
            _user,
            _planId,
            plan.tokenIn,
            plan.tokenOut,
            swapAmount,
            amountOut,
            feeAmount
        );
    }

    function cancelPlan(uint256 _planId) external override {
        require(_planId < userPlanCount[msg.sender], "Invalid plan ID");
        DCAPlan storage plan = userPlans[msg.sender][_planId];
        require(plan.active, "No active plan");

        plan.active = false;

        emit PlanCancelled(msg.sender, _planId);
    }

    function getAllUserPlans(
        address _user
    ) external view returns (DCAPlan[] memory) {
        uint256 count = userPlanCount[_user];
        DCAPlan[] memory plans = new DCAPlan[](count);

        for (uint256 i = 0; i < count; i++) {
            plans[i] = userPlans[_user][i];
        }

        return plans;
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
        address _to,
        uint256 _amount
    ) external override onlyOwner nonReentrant {
        require(_amount > 0, "Amount must be > 0");
        uint256 balance = IERC20(_token).balanceOf(address(this));
        require(balance >= _amount, "Not enough fees, chief");
        IERC20(_token).transfer(_to, _amount);
        emit FeeWithdrawn(_token, _to, _amount);
    }

    function withdrawETH(
        address _to,
        uint256 _amount
    ) external onlyOwner nonReentrant {
        require(_to != address(0), "Invalid recipient");
        require(address(this).balance >= _amount, "Not enough ETH");

        (bool success, ) = _to.call{value: _amount}("");
        require(success, "ETH transfer failed");
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
