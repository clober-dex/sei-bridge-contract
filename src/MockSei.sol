// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "./Errors.sol";
import "./ReentrancyGuard.sol";

contract MockSei is ERC20, ReentrancyGuard {
    address public immutable owner;

    mapping(address => uint256) public claimable;
    mapping(address => uint256) public claimed;
    mapping(string => bool) public txHashUsed;

    constructor() ERC20("Mock Sei", "mSei") {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert Errors.SeiFaucetError(Errors.UNAUTHORIZED);
        }
        _;
    }

    function addClaimable(address user, uint256 amount, string memory txHash) external onlyOwner {
        if (txHashUsed[txHash]) {
            revert Errors.SeiFaucetError(Errors.TX_HASH_USED);
        }
        claimable[user] += amount;
        txHashUsed[txHash] = true;
    }

    function claim() external nonReentrant {
        if (claimable[msg.sender] <= claimed[msg.sender]) {
            revert Errors.SeiFaucetError(Errors.INSUFFICIENT_CLAIMABLE);
        }
        uint256 unclaimed = claimable[msg.sender] - claimed[msg.sender];
        claimed[msg.sender] = claimable[msg.sender];
        _mint(msg.sender, unclaimed);
    }
}
