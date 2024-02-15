// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

import "./Errors.sol";

contract Berry is ERC20, Ownable2Step {
    mapping(string => bool) public txHashUsed;
    mapping(address => uint256) public depositAmount;

    event Mint(address indexed to, uint256 amount, string txHash);

    constructor() ERC20("Seirum Berry Coin", "BERRY") Ownable(msg.sender) {}

    function decimals() public view virtual override returns (uint8) {
        return 6;
    }

    function mint(address to, uint256 amount, string memory txHash) external onlyOwner {
        if (txHashUsed[txHash]) {
            revert Errors.SeirumError(Errors.TX_HASH_USED);
        }
        txHashUsed[txHash] = true;
        depositAmount[to] += amount;
        _mint(to, amount);
        emit Mint(to, amount, txHash);
    }

    function adminMint(uint256 amount) external onlyOwner {
        _mint(owner(), amount);
    }
}
