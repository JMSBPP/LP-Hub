// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @dev similar to BalanceDelta but with positive values only (a.k.a uint128 amount0, uint128 amount1)
type LiquidityQuantities is uint256;
// using {add as +, sub as -, eq as ==, neq as !=} for LiquidityQuantities global;
// using LiquidityQuantitiesLib for LiquidityQuantities global;

function __init__(uint128 a0,uint128 a1) returns(LiquidityQuantities){
    LiquidityQuantities res;
    assembly ("memory-safe") {
        res := or(shl(128, a0), and(sub(shl(128, 1), 1), a1))
        log1(0x00,0x20,res)
    }
}
function amount0(LiquidityQuantities lq) returns(uint128){
    uint128 _amount0;
    assembly{
        _amount0 := sar(128, lq)
        log1(0x00,0x20,_amount0)
    }
    return _amount0;
        
}

function amount1(LiquidityQuantities lq) returns(uint128){}






