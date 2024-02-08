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
        string memory txHash = "02C33440F07451D69A6B1399E290F24FF7006F4CC047D25CA7CEDAFA8797C46C";

        // before adding claimable
        assertEq(mockSei.claimable(user), 0);
        // add claimable
        mockSei.addClaimable(user, amount, txHash);
        // after adding claimable
        assertEq(mockSei.claimable(user), amount);
    }

    function testFuzz_IncreaseClaimable(address user) public {
        uint256 amount1 = 42 * PRECISION;
        uint256 amount2 = 69 * PRECISION;

        string memory txHash1 = "02C33440F07451D69A6B1399E290F24FF7006F4CC047D25CA7CEDAFA8797C46C";
        string memory txHash2 = "02C33440F07451D69A6B1399E290F24FF7006F4CC047D25CA7CEDAFA8797C42C";

        // before adding claimable
        assertEq(mockSei.claimable(user), 0);
        // add claimable
        mockSei.addClaimable(user, amount1, txHash1);
        // after adding claimable
        assertEq(mockSei.claimable(user), amount1);
        // increase claimable
        mockSei.addClaimable(user, amount2, txHash2);
        // after increasing claimable
        assertEq(mockSei.claimable(user), amount1 + amount2);
    }

    function testFuzz_IncreaseClaimableUsingSameTxHash(address user) public {
        uint256 amount1 = 42 * PRECISION;
        uint256 amount2 = 69 * PRECISION;

        string memory txHash = "02C33440F07451D69A6B1399E290F24FF7006F4CC047D25CA7CEDAFA8797C46C";

        // before adding claimable
        assertEq(mockSei.claimable(user), 0);
        // add claimable
        mockSei.addClaimable(user, amount1, txHash);
        // after adding claimable
        assertEq(mockSei.claimable(user), amount1);
        // increase claimable using same txHash
        vm.expectRevert(abi.encodeWithSelector(Errors.SeiFaucetError.selector, Errors.TX_HASH_USED));
        mockSei.addClaimable(user, amount2, txHash);
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
        string memory txHash = "02C33440F07451D69A6B1399E290F24FF7006F4CC047D25CA7CEDAFA8797C46C";
        // prank random user
        address user = address(bytes20(keccak256(abi.encodePacked(seed))));
        // add claimable
        mockSei.addClaimable(user, amount, txHash);
        // claim
        vm.prank(user);
        mockSei.claim();
        // claim again
        vm.expectRevert(abi.encodeWithSelector(Errors.SeiFaucetError.selector, Errors.INSUFFICIENT_CLAIMABLE));
        mockSei.claim();
    }

    function testFuzz_Claim(uint16 seed) public {
        uint256 amount = 42 * PRECISION;
        string memory txHash = "02C33440F07451D69A6B1399E290F24FF7006F4CC047D25CA7CEDAFA8797C46C";
        // prank random user
        address user = address(bytes20(keccak256(abi.encodePacked(seed))));
        // add claimable
        mockSei.addClaimable(user, amount, txHash);
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
        string memory txHash1 = "02C33440F07451D69A6B1399E290F24FF7006F4CC047D25CA7CEDAFA8797C46C";
        string memory txHash2 = "02C33440F07451D69A6B1399E290F24FF7006F4CC047D25CA7CEDAFA8797C42C";
        // prank random user
        address user = address(bytes20(keccak256(abi.encodePacked(seed))));
        // add claimable
        mockSei.addClaimable(user, amount1, txHash1);
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
        mockSei.addClaimable(user, amount2, txHash2);
        // claim
        vm.prank(user);
        mockSei.claim();
        // check claimed & balance
        assertEq(mockSei.claimed(user), amount1 + amount2);
        assertEq(mockSei.balanceOf(user), amount1 + amount2);
    }
}
