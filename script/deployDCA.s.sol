// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "forge-std/Script.sol";
import "../src/DCAExecutor.sol";

contract DeployDCA is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PVT_KEY");

        vm.startBroadcast(deployerPrivateKey);

        address swapRouter = 0x2626664c2603336E57B271c5C0b26F421741e481;
        uint256 feePercent = 50;

        DCAExecutor dcaExecutor = new DCAExecutor(swapRouter, feePercent);

        console2.log("DCAExecutor deployed at:", address(dcaExecutor));
        dcaExecutor.setAdmin(vm.envAddress("OWNER_ADDRESS"), true);
        dcaExecutor.transferOwnership(vm.envAddress("OWNER_ADDRESS"));

        vm.stopBroadcast();
    }
}
