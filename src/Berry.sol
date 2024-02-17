// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

import "./Errors.sol";

contract Berry is ERC20, Ownable2Step {
    mapping(string => bool) public txHashUsed;
    mapping(address => uint256) public depositAmount;
    mapping(address => string) public accountOwner;

    event Mint(address indexed to, uint256 amount, string txHash, string from);

    constructor() ERC20("Seirum Berry Coin", "BERRY") Ownable(msg.sender) {}

    function decimals() public view virtual override returns (uint8) {
        return 6;
    }

    function mint(address to, uint256 amount, string memory txHash, string memory from) external onlyOwner {
        // check to, amount, txHash, from is not empty
        if (to == address(0) || amount == 0 || bytes(txHash).length == 0 || bytes(from).length == 0) {
            revert Errors.SeirumError(Errors.INVALID_INPUT);
        }
        if (txHashUsed[txHash]) {
            revert Errors.SeirumError(Errors.TX_HASH_USED);
        }
        if (bytes(accountOwner[to]).length != 0 && keccak256(abi.encodePacked(accountOwner[to])) != keccak256(abi.encodePacked(from))) {
            revert Errors.SeirumError(Errors.ACCOUNT_OWNER_NOT_MATCH);
        }
        txHashUsed[txHash] = true;
        accountOwner[to] = from;
        depositAmount[to] += amount;
        _mint(to, amount);
        emit Mint(to, amount, txHash, from);
    }

    function adminMint(uint256 amount) external onlyOwner {
        _mint(owner(), amount);
    }
}
