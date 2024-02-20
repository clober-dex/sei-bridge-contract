// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";

import {Beri} from "../src/Beri.sol";
import {Buck} from "../src/Buck.sol";

contract SeirumCoinDeployScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        Beri beri = new Beri();
        Buck buck = new Buck();
        console.log(address(beri));
        console.log(address(buck));
        vm.stopBroadcast();
    }
}