// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol"; 
import "@cryptoalgebra/integral-periphery/contracts/libraries/LiquidityAmounts.sol";

contract TestDependencyImport is Test {
    function testExample() external view {
        console.log("Successfully imported forge-std/Test.sol");
        assert(true);
    }
}