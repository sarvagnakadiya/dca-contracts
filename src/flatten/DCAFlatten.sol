// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

// lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/IERC20.sol)

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

// lib/openzeppelin-contracts/contracts/utils/Context.sol

// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol

// OpenZeppelin Contracts (last updated v5.1.0) (utils/ReentrancyGuard.sol)

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If EIP-1153 (transient storage) is available on the chain you're deploying at,
 * consider using {ReentrancyGuardTransient} instead.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}

// src/Interfaces/IDCAExecutor.sol

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
        uint256 indexed planId,
        address indexed tokenIn,
        address tokenOut,
        address recipient,
        uint256 duration
    );

    event PlanUpdated(
        address indexed user,
        uint256 indexed planId,
        address recipient,
        uint256 duration
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
        address _recipient,
        uint256 _duration
    ) external;
    function updatePlan(
        uint256 _planId,
        address _recipient,
        uint256 _duration
    ) external;
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

// src/Interfaces/ISwapRouter.sol

interface ISwapRouter {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactInputSingleParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInputSingle(
        ExactInputSingleParams calldata params
    ) external payable returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another along the specified path
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactInputParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInput(
        ExactInputParams calldata params
    ) external payable returns (uint256 amountOut);

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactOutputSingleParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutputSingle(
        ExactOutputSingleParams calldata params
    ) external payable returns (uint256 amountIn);

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another along the specified path (reversed)
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactOutputParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutput(
        ExactOutputParams calldata params
    ) external payable returns (uint256 amountIn);
}

// lib/openzeppelin-contracts/contracts/access/Ownable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// src/Interfaces/IWETH9.sol

/// @title Interface for WETH9
interface IWETH9 is IERC20 {
    /// @notice Withdraw wrapped ether to get ether
    function withdraw(uint256) external;
}

// src/DCAExecutor.sol

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
        address _recipient,
        uint256 _duration
    ) external override {
        require(_tokenIn != _tokenOut, "TokenIn == TokenOut?? bruh");
        require(_duration > 0, "Duration must be > 0");
        require(_recipient != address(0), "Invalid recipient");

        uint256 planId = userPlanCount[msg.sender];
        userPlans[msg.sender].push(
            DCAPlan({
                tokenIn: _tokenIn,
                tokenOut: _tokenOut,
                recipient: _recipient,
                lastExecution: 0,
                duration: _duration,
                active: true
            })
        );
        userPlanCount[msg.sender]++;

        emit PlanCreated(
            msg.sender,
            planId,
            _tokenIn,
            _tokenOut,
            _recipient,
            _duration
        );
    }

    function updatePlan(
        uint256 _planId,
        address _recipient,
        uint256 _duration
    ) external override {
        require(_planId < userPlanCount[msg.sender], "Invalid plan ID");
        DCAPlan storage plan = userPlans[msg.sender][_planId];
        require(plan.active, "No active plan");
        require(_duration > 0, "Duration must be > 0");
        require(_recipient != address(0), "Invalid recipient");

        plan.recipient = _recipient;
        plan.duration = _duration;

        emit PlanUpdated(msg.sender, _planId, _recipient, _duration);
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
                recipient: plan.tokenOut == WETH
                    ? address(this)
                    : plan.recipient,
                amountIn: swapAmount,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        amountOut = ISwapRouter(swapRouter).exactInputSingle(params);
        plan.lastExecution = block.timestamp;

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
