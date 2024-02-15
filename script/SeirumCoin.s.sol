// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";

import {Berry} from "../src/Berry.sol";
import {Buck} from "../src/Buck.sol";

contract SeirumCoinDeployScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        Berry berry = new Berry();
        Buck buck = new Buck();
        console.log(address(berry));
        console.log(address(buck));
        vm.stopBroadcast();
    }
}