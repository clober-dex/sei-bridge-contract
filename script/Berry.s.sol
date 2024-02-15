// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";

import {Berry} from "../src/Berry.sol";

contract MockSeiScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        Berry mockSei = new Berry();
        console.log(address(mockSei));
        vm.stopBroadcast();
    }
}