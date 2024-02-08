// SPDX-License-Identifier: -
// License: -

pragma solidity ^0.8.0;

library Errors {
    error SeiFaucetError(uint256 errorCode);

    uint256 public constant INSUFFICIENT_CLAIMABLE = 0;
    uint256 public constant REENTRANCY = 1;
    uint256 public constant UNAUTHORIZED = 2;
    uint256 public constant TX_HASH_USED = 3;
}
