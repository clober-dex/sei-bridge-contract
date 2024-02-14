// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {MockSei} from "../src/MockSei.sol";
import {Errors} from "../src/Errors.sol";

contract MockSeiTest is Test {
    uint256 public constant PRECISION = 10**18;

    MockSei public mockSei;

    event Mint(address indexed to, uint256 amount, string txHash);

    function setUp() public {
        mockSei = new MockSei();
    }

    function testFuzz_mint(uint16 seed) public {
        address user = address(bytes20(keccak256(abi.encodePacked(seed))));
        uint256 amount = 101 * PRECISION;
        string memory txHash = "02C33440F07451D69A6B1399E290F24FF7006F4CC047D25CA7CEDAFA8797C46C";

        // before mint
        assertEq(mockSei.balanceOf(user), 0);
        // expect mint event
        vm.expectEmit();
        emit Mint(user, amount, txHash);
        // mint
        mockSei.mint(user, amount, txHash);
        // after mint
        assertEq(mockSei.balanceOf(user), amount);
    }

    function testFuzz_MintUsingSameTxHash(uint16 seed) public {
        address user = address(bytes20(keccak256(abi.encodePacked(seed))));
        uint256 amount1 = 42 * PRECISION;
        uint256 amount2 = 69 * PRECISION;

        string memory txHash = "02C33440F07451D69A6B1399E290F24FF7006F4CC047D25CA7CEDAFA8797C46C";

        // mint
        mockSei.mint(user, amount1, txHash);
        // mint using same txHash
        vm.expectRevert(abi.encodeWithSelector(Errors.SeiFaucetError.selector, Errors.TX_HASH_USED));
        mockSei.mint(user, amount2, txHash);
    }
}
