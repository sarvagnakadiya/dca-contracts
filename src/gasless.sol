// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Interface/IUSDC.sol";

contract PermitUSDCCollector {
    IUSDC public immutable usdc =
        IUSDC(0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913);

    function permitAndCollect(
        uint256 amount,
        uint256 deadline,
        address receiver,
        bytes memory signature
    ) external {
        // 1. Permit: Allow this contract to spend user's USDC
        usdc.permit(msg.sender, address(this), amount, deadline, signature);

        // 2. Transfer the USDC to receiver
        bool success = usdc.transferFrom(msg.sender, receiver, amount);
        require(success, "USDC transfer failed");
    }
}
