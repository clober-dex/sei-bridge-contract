// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {MockSei} from "../src/MockSei.sol";
import {Errors} from "../src/Errors.sol";

contract MockSeiTest is Test {
    uint256 public constant PRECISION = 10**18;

    MockSei public mockSei;

    function setUp() public {
        mockSei = new MockSei();
    }

    function testFuzz_AddClaimable(address user) public {
        uint256 amount = 101 * PRECISION;

        // before adding claimable
        assertEq(mockSei.claimable(user), 0);
        // add claimable
        mockSei.addClaimable(user, amount);
        // after adding claimable
        assertEq(mockSei.claimable(user), amount);
    }

    function testFuzz_IncreaseClaimable(address user) public {
        uint256 amount1 = 42 * PRECISION;
        uint256 amount2 = 69 * PRECISION;

        // before adding claimable
        assertEq(mockSei.claimable(user), 0);
        // add claimable
        mockSei.addClaimable(user, amount1);
        // after adding claimable
        assertEq(mockSei.claimable(user), amount1);
        // increase claimable
        mockSei.addClaimable(user, amount2);
        // after increasing claimable
        assertEq(mockSei.claimable(user), amount1 + amount2);
    }

    function test_ClaimBeforeAddingClaimable(uint16 seed) public {
        // prank random user
        address user = address(bytes20(keccak256(abi.encodePacked(seed))));
        vm.prank(user);
        // claim before adding claimable
        vm.expectRevert(abi.encodeWithSelector(Errors.SeiFaucetError.selector, Errors.INSUFFICIENT_CLAIMABLE));
        mockSei.claim();
    }

    function testFuzz_ClaimTwiceWithNoUnclaimedAmount(uint16 seed) public {
        uint256 amount = 42 * PRECISION;
        // prank random user
        address user = address(bytes20(keccak256(abi.encodePacked(seed))));
        // add claimable
        mockSei.addClaimable(user, amount);
        // claim
        vm.prank(user);
        mockSei.claim();
        // claim again
        vm.expectRevert(abi.encodeWithSelector(Errors.SeiFaucetError.selector, Errors.INSUFFICIENT_CLAIMABLE));
        mockSei.claim();
    }

    function testFuzz_Claim(uint16 seed) public {
        uint256 amount = 42 * PRECISION;
        // prank random user
        address user = address(bytes20(keccak256(abi.encodePacked(seed))));
        // add claimable
        mockSei.addClaimable(user, amount);
        // check claimable & claimed & balance
        assertEq(mockSei.claimable(user), amount);
        assertEq(mockSei.claimed(user), 0);
        assertEq(mockSei.balanceOf(user), 0);
        // claim
        vm.prank(user);
        mockSei.claim();
        // check claimed & balance
        assertEq(mockSei.claimed(user), amount);
        assertEq(mockSei.balanceOf(user), amount);
    }

    function testFuzz_ClaimTwice(uint16 seed) public {
        uint256 amount1 = 42 * PRECISION;
        uint256 amount2 = 69 * PRECISION;

        // prank random user
        address user = address(bytes20(keccak256(abi.encodePacked(seed))));
        // add claimable
        mockSei.addClaimable(user, amount1);
        // check claimed & balance
        assertEq(mockSei.claimed(user), 0);
        assertEq(mockSei.balanceOf(user), 0);
        // claim
        vm.prank(user);
        mockSei.claim();
        // check claimed & balance
        assertEq(mockSei.claimed(user), amount1);
        assertEq(mockSei.balanceOf(user), amount1);
        // add claimable
        mockSei.addClaimable(user, amount2);
        // claim
        vm.prank(user);
        mockSei.claim();
        // check claimed & balance
        assertEq(mockSei.claimed(user), amount1 + amount2);
        assertEq(mockSei.balanceOf(user), amount1 + amount2);
    }
}
