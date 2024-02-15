// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Berry} from "../src/Berry.sol";
import {Errors} from "../src/Errors.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

contract BerryTest is Test {
    uint256 public constant PRECISION = 10**18;
    uint8 public constant DECIMALS = 6;

    Berry public berry;

    event Mint(address indexed to, uint256 amount, string txHash);

    function setUp() public {
        berry = new Berry();
    }

    function test_Decimals() public {
        assertEq(berry.decimals(), DECIMALS);
    }

    function testFuzz_mint(uint16 seed) public {
        address user = address(bytes20(keccak256(abi.encodePacked(seed))));
        uint256 amount = 101 * PRECISION;
        string memory txHash = "02C33440F07451D69A6B1399E290F24FF7006F4CC047D25CA7CEDAFA8797C46C";

        // before mint
        assertEq(berry.balanceOf(user), 0);
        // expect mint event
        vm.expectEmit();
        emit Mint(user, amount, txHash);
        // mint
        berry.mint(user, amount, txHash);
        // after mint
        assertEq(berry.balanceOf(user), amount);
        assertEq(berry.depositAmount(user), amount);
    }

    function testFuzz_MintUsingSameTxHash(uint16 seed) public {
        address user = address(bytes20(keccak256(abi.encodePacked(seed))));
        uint256 amount1 = 42 * PRECISION;
        uint256 amount2 = 69 * PRECISION;

        string memory txHash = "02C33440F07451D69A6B1399E290F24FF7006F4CC047D25CA7CEDAFA8797C46C";

        // mint
        berry.mint(user, amount1, txHash);
        // mint using same txHash
        vm.expectRevert(abi.encodeWithSelector(Errors.SeirumError.selector, Errors.TX_HASH_USED));
        berry.mint(user, amount2, txHash);
    }

    function testFuzz_roleCheck(uint16 seed) public {
        address user = address(bytes20(keccak256(abi.encodePacked(seed))));

        vm.startPrank(user);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, user));
        berry.mint(user, 100 * PRECISION, "02C33440F07451D69A6B1399E290F24FF7006F4CC047D25CA7CEDAFA8797C46C");

        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, user));
        berry.adminMint(100 * PRECISION);

        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, user));
        berry.pause();
        vm.stopPrank();
    }

    function testFuzz_pause(uint16 seed) public {
        address user = address(bytes20(keccak256(abi.encodePacked(seed))));

        berry.pause();
        vm.expectRevert(abi.encodeWithSelector(Errors.SeirumError.selector, Errors.PAUSED));
        berry.mint(user, 100 * PRECISION, "02C33440F07451D69A6B1399E290F24FF7006F4CC047D25CA7CEDAFA8797C46C");
    }

    function test_adminMint() public {
        uint256 amount = 100 * PRECISION;

        // before mint
        assertEq(berry.balanceOf(address(this)), 0);
        // mint
        berry.adminMint(amount);
        // after mint
        assertEq(berry.balanceOf(address(this)), amount);
    }
}
