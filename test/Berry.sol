// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Berry} from "../src/Berry.sol";
import {Errors} from "../src/Errors.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

contract BerryTest is Test {
    uint256 public constant PRECISION = 10**18;
    uint8 public constant DECIMALS = 6;
    string public constant COSMOS_ADDRESS = "sei1jtaud9fjknryvw9y8yqvc9sqcn0g6shl5fkatn";
    string public constant SEI_PRICE = "0.9123";

    Berry public berry;

    event Mint(address indexed to, uint256 amount, string txHash, string from, string price);

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
        emit Mint(user, amount, txHash, COSMOS_ADDRESS, SEI_PRICE);
        // mint
        berry.mint(user, amount, txHash, COSMOS_ADDRESS, SEI_PRICE);
        // after mint
        assertEq(berry.balanceOf(user), amount);
        assertEq(berry.depositAmount(user), amount);
    }

    function testFuzz_mintTwice(uint16 seed) public {
        address user = address(bytes20(keccak256(abi.encodePacked(seed))));
        uint256 amount = 101 * PRECISION;
        string memory txHash1 = "02C33440F07451D69A6B1399E290F24FF7006F4CC047D25CA7CEDAFA8797C46C";
        string memory txHash2 = "02C33440F07451D69A6B1399E290F24FF7006F4CC047D25CA7CEDAFA8797C46D";

        // before mint
        assertEq(berry.balanceOf(user), 0);
        // expect mint event
        vm.expectEmit();
        emit Mint(user, amount, txHash1, COSMOS_ADDRESS, SEI_PRICE);
        // mint
        berry.mint(user, amount, txHash1, COSMOS_ADDRESS, SEI_PRICE);
        // expect mint event
        vm.expectEmit();
        emit Mint(user, amount, txHash2, COSMOS_ADDRESS, SEI_PRICE);
        // and again
        berry.mint(user, amount, txHash2, COSMOS_ADDRESS, SEI_PRICE);
        // after mint
        assertEq(berry.balanceOf(user), amount * 2);
        assertEq(berry.depositAmount(user), amount * 2);
    }

    function testFuzz_mintWithZeroAmount(uint16 seed) public {
        address user = address(bytes20(keccak256(abi.encodePacked(seed))));
        uint256 amount = 0;
        string memory txHash = "02C33440F07451D69A6B1399E290F24FF7006F4CC047D25CA7CEDAFA8797C46C";

        // before mint
        assertEq(berry.balanceOf(user), 0);
        // expect revert
        vm.expectRevert(abi.encodeWithSelector(Errors.SeirumError.selector, Errors.INVALID_INPUT));
        // mint
        berry.mint(user, amount, txHash, COSMOS_ADDRESS, SEI_PRICE);
    }

    function test_mintWithEmptyUser() public {
        address user = address(0);
        uint256 amount = 101 * PRECISION;
        string memory txHash = "02C33440F07451D69A6B1399E290F24FF7006F4CC047D25CA7CEDAFA8797C46C";

        // before mint
        assertEq(berry.balanceOf(user), 0);
        // expect revert
        vm.expectRevert(abi.encodeWithSelector(Errors.SeirumError.selector, Errors.INVALID_INPUT));
        // mint
        berry.mint(user, amount, txHash, COSMOS_ADDRESS, SEI_PRICE);
    }

    function testFuzz_mintWithEmptyTxHash(uint16 seed) public {
        address user = address(bytes20(keccak256(abi.encodePacked(seed))));
        uint256 amount = 101 * PRECISION;
        string memory txHash = "";

        // before mint
        assertEq(berry.balanceOf(user), 0);
        // expect revert
        vm.expectRevert(abi.encodeWithSelector(Errors.SeirumError.selector, Errors.INVALID_INPUT));
        // mint
        berry.mint(user, amount, txHash, COSMOS_ADDRESS, SEI_PRICE);
    }

    function testFuzz_mintWithEmptyFrom(uint16 seed) public {
        address user = address(bytes20(keccak256(abi.encodePacked(seed))));
        uint256 amount = 101 * PRECISION;
        string memory txHash = "02C33440F07451D69A6B1399E290F24FF7006F4CC047D25CA7CEDAFA8797C46C";
        string memory from = "";

        // before mint
        assertEq(berry.balanceOf(user), 0);
        // expect revert
        vm.expectRevert(abi.encodeWithSelector(Errors.SeirumError.selector, Errors.INVALID_INPUT));
        // mint
        berry.mint(user, amount, txHash, from, SEI_PRICE);
    }

    function testFuzz_mintTwiceWithDifferentOwner(uint16 seed) public {
        address user = address(bytes20(keccak256(abi.encodePacked(seed))));
        string memory cosmosAddress1 = "sei1jtaud9fjknryvw9y8yqvc9sqcn0g6shl5fkatn";
        string memory cosmosAddress2 = "sei1jtaud9fjknryvw9y8yqvc9sqcn0g6shl5fkatm";

        uint256 amount = 101 * PRECISION;
        string memory txHash1 = "02C33440F07451D69A6B1399E290F24FF7006F4CC047D25CA7CEDAFA8797C46C";
        string memory txHash2 = "02C33440F07451D69A6B1399E290F24FF7006F4CC047D25CA7CEDAFA8797C46D";

        // before mint
        assertEq(berry.balanceOf(user), 0);
        // expect mint event
        vm.expectEmit();
        emit Mint(user, amount, txHash1, cosmosAddress1, SEI_PRICE);
        // mint
        berry.mint(user, amount, txHash1, cosmosAddress1, SEI_PRICE);
        // expect revert
        vm.expectRevert(abi.encodeWithSelector(Errors.SeirumError.selector, Errors.COSMOS_EVM_ADDRESSES_NOT_MATCH));
        // and again
        berry.mint(user, amount, txHash2, cosmosAddress2, SEI_PRICE);
    }

    function test_mintTwiceWithDifferentAddress() public {
        uint16 seed1 = 1;
        uint16 seed2 = 2;
        address user1 = address(bytes20(keccak256(abi.encodePacked(seed1))));
        address user2 = address(bytes20(keccak256(abi.encodePacked(seed2))));

        uint256 amount = 101 * PRECISION;
        string memory txHash1 = "02C33440F07451D69A6B1399E290F24FF7006F4CC047D25CA7CEDAFA8797C46C";
        string memory txHash2 = "02C33440F07451D69A6B1399E290F24FF7006F4CC047D25CA7CEDAFA8797C46D";

        // before mint
        assertEq(berry.balanceOf(user1), 0);
        // expect mint event
        vm.expectEmit();
        emit Mint(user1, amount, txHash1, COSMOS_ADDRESS, SEI_PRICE);
        // mint
        berry.mint(user1, amount, txHash1, COSMOS_ADDRESS, SEI_PRICE);
        // after mint
        assertEq(berry.balanceOf(user1), amount);
        // expect revert
        vm.expectRevert(abi.encodeWithSelector(Errors.SeirumError.selector, Errors.COSMOS_EVM_ADDRESSES_NOT_MATCH));
        // and again
        berry.mint(user2, amount, txHash2, COSMOS_ADDRESS, SEI_PRICE);
    }

    function testFuzz_MintUsingSameTxHash(uint16 seed) public {
        address user = address(bytes20(keccak256(abi.encodePacked(seed))));
        uint256 amount1 = 42 * PRECISION;
        uint256 amount2 = 69 * PRECISION;

        string memory txHash = "02C33440F07451D69A6B1399E290F24FF7006F4CC047D25CA7CEDAFA8797C46C";

        // mint
        berry.mint(user, amount1, txHash, COSMOS_ADDRESS, SEI_PRICE);
        // mint using same txHash
        vm.expectRevert(abi.encodeWithSelector(Errors.SeirumError.selector, Errors.TX_HASH_USED));
        berry.mint(user, amount2, txHash, COSMOS_ADDRESS, SEI_PRICE);
    }

    function testFuzz_roleCheck(uint16 seed) public {
        address user = address(bytes20(keccak256(abi.encodePacked(seed))));
        string memory txHash = "02C33440F07451D69A6B1399E290F24FF7006F4CC047D25CA7CEDAFA8797C46C";

        vm.startPrank(user);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, user));
        berry.mint(user, 100 * PRECISION, txHash, COSMOS_ADDRESS, SEI_PRICE);

        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, user));
        berry.adminMint(100 * PRECISION);

        vm.stopPrank();
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
