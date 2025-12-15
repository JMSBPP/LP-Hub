// // SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2} from "forge-std/Test.sol";
import "../src/types/LiquidityQuantities.sol" as LiquidityQuantitiesMod;

contract LiquidityQuantitiesTest is Test{
    function setUp() public {}
    
    function test__fuzz__unpackLiquidityQuantities(uint128 a0,uint128 a1) public {
        LiquidityQuantitiesMod.LiquidityQuantities res = LiquidityQuantitiesMod.__init__(a0,a1);
        
        uint128 res0 = LiquidityQuantitiesMod.amount0(res);
        console2.log(res0);
    }    
}