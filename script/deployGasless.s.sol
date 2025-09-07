// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {PermitUSDCCollector} from "../src/gasless.sol";

contract GaslessScript is Script {
    PermitUSDCCollector public permitUSDCCollector;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        permitUSDCCollector = new PermitUSDCCollector();
        console.log(
            "PermitUSDCCollector deployed to: %s",
            address(permitUSDCCollector)
        );

        vm.stopBroadcast();
    }
}
