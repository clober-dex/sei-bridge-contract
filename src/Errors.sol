// SPDX-License-Identifier: -
// License: -

pragma solidity ^0.8.0;

library Errors {
    error SeirumError(uint256 errorCode);

    uint256 public constant TX_HASH_USED = 0;
    uint256 public constant PAUSED = 1;
    uint256 public constant ACCOUNT_OWNER_NOT_MATCH = 2;
    uint256 public constant INVALID_INPUT = 3;
}
