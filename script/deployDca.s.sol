// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {DCAForwarder} from "../src/DCA.sol";

contract DCAForwarderScript is Script {
    DCAForwarder public dcaForwarder;
    address ADMIN = vm.envAddress("ADMIN_ADDRESS");
    address OWNER = vm.envAddress("OWNER_ADDRESS");
    address USDC = vm.envAddress("USDC_ADDRESS");
    address WETH = vm.envAddress("WETH_ADDRESS");
    address ROUTER = vm.envAddress("ROUTER_ADDRESS");

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        dcaForwarder = new DCAForwarder(
            ROUTER,
            OWNER,
            USDC,
            0,
            0x0000000000000000000000000000000000000000,
            WETH
        );
        // dcaForwarder.setAdmin(ADMIN, true);
        console.log("DCAForwarder deployed to: %s", address(dcaForwarder));

        vm.stopBroadcast();
    }
}
