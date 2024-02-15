// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

contract Buck is ERC20, Ownable2Step {
    constructor() ERC20("Seirum Dollar", "BUCK") Ownable(msg.sender) {}

    function decimals() public view virtual override returns (uint8) {
        return 6;
    }

    function adminMint(uint256 amount) external onlyOwner {
        _mint(owner(), amount);
    }
}
