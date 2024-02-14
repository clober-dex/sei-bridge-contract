// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "./Errors.sol";
import "./ReentrancyGuard.sol";

contract MockSei is ERC20, ReentrancyGuard {
    address public immutable owner;

    mapping(string => bool) public txHashUsed;

    event Mint(address indexed to, uint256 amount, string txHash);

    constructor() ERC20("Mock Sei", "mSei") {
        owner = msg.sender;
    }

    function decimals() public view virtual override returns (uint8) {
        return 6;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert Errors.SeiFaucetError(Errors.UNAUTHORIZED);
        }
        _;
    }

    function mint(address to, uint256 amount, string memory txHash) external onlyOwner {
        if (txHashUsed[txHash]) {
            revert Errors.SeiFaucetError(Errors.TX_HASH_USED);
        }
        txHashUsed[txHash] = true;
        _mint(to, amount);
        emit Mint(to, amount, txHash);
    }
}
