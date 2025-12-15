// // SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {console2} from "forge-std/console2.sol";
import {LiquidityAmounts} from "@uniswap/v4-core/test/utils/LiquidityAmounts.sol";
import "@uniswap-foundation/libraries/SqrtPriceLibrary.sol";
import {FullMath} from "@uniswap/v4-core/src/libraries/FullMath.sol";

import "@uniswap/v4-core/src/types/BalanceDelta.sol";

struct SqrtPriceX96Range{
    uint160 low;
    uint160 up;
}

function __init__(SqrtPriceX96Range memory _in) returns (SqrtPriceX96Range memory){
    return (SqrtPriceX96Range(_in.up > _in.low ? _in.low:_in.up,_in.up>_in.low?_in.up:_in.low));
}

enum AMOUNTS_TO_ENTER{
    IS_ZERO,
    IS_ONE,
    ARE_BOTH
}



struct Liquidity{
    uint128 liquidity;
    uint256 liquidity0;
    uint256 liquidity1;
}

function entryLiquidity(
    uint160 currentSqrtPriceX96,
    SqrtPriceX96Range memory sqrtPriceX96Range,
    BalanceDelta tokenAmounts
) returns(Liquidity memory){

    sqrtPriceX96Range = __init__(sqrtPriceX96Range);
    Liquidity memory _liquidity;
    uint256 amount0 = uint256(uint128(BalanceDeltaLibrary.amount0(tokenAmounts) < 0 ? -BalanceDeltaLibrary.amount0(tokenAmounts):BalanceDeltaLibrary.amount0(tokenAmounts)));
    {
        if (currentSqrtPriceX96 < sqrtPriceX96Range.low){
           _liquidity.liquidity = LiquidityAmounts.getLiquidityForAmount0(currentSqrtPriceX96, sqrtPriceX96Range.low, amount0);

        }

        if (currentSqrtPriceX96 > sqrtPriceX96Range.low && currentSqrtPriceX96 < sqrtPriceX96Range.up){
            _liquidity.liquidity = LiquidityAmounts.getLiquidityForAmount0(currentSqrtPriceX96, sqrtPriceX96Range.up, amount0);
        }
    }
    
    uint256 amount1 = uint256(uint128(BalanceDeltaLibrary.amount1(tokenAmounts) < 0 ? -BalanceDeltaLibrary.amount1(tokenAmounts):BalanceDeltaLibrary.amount1(tokenAmounts)));
    {
        if (currentSqrtPriceX96 > sqrtPriceX96Range.low && currentSqrtPriceX96 < sqrtPriceX96Range.up){
           console2.log("Here");
            _liquidity.liquidity = LiquidityAmounts.getLiquidityForAmount1(currentSqrtPriceX96, sqrtPriceX96Range.low, amount1);
        }

        if (currentSqrtPriceX96 > sqrtPriceX96Range.up){
            _liquidity.liquidity = LiquidityAmounts.getLiquidityForAmount1(sqrtPriceX96Range.low, sqrtPriceX96Range.up, amount1);
        }

    }

    (_liquidity.liquidity0, _liquidity.liquidity1) = LiquidityAmounts.getAmountsForLiquidity(
        currentSqrtPriceX96,
        sqrtPriceX96Range.low,
        sqrtPriceX96Range.up,
        _liquidity.liquidity
    );
    return _liquidity;
}


function multiplier(uint160 sqrtPriceX96,SqrtPriceX96Range memory sqrtPriceX96Range,BalanceDelta tokenAmounts) returns(uint256){
    
    if (sqrtPriceX96 <= sqrtPriceX96Range.low){
        return 1;
    }
    if (sqrtPriceX96 > sqrtPriceX96Range.low && sqrtPriceX96 < sqrtPriceX96Range.up){
        
        uint256 divX96= SqrtPriceLibrary.divX96(sqrtPriceX96, sqrtPriceX96Range.low);
        uint160 rangeLen = SqrtPriceLibrary.absDifferenceX96(
            sqrtPriceX96Range.up,
            sqrtPriceX96Range.low
        );
        uint160 priceDiff = SqrtPriceLibrary.absDifferenceX96(
            sqrtPriceX96Range.up
            ,
            sqrtPriceX96 
        );
        return uint160(FullMath.mulDiv(divX96, uint256(rangeLen), uint256(priceDiff)));

    }

    if (sqrtPriceX96 > sqrtPriceX96Range.up){
        return uint256(sqrtPriceX96Range.up*sqrtPriceX96Range.low);
    }
}

function entryLiquidityPosition(
    uint160 sqrtPriceX96,SqrtPriceX96Range memory sqrtPriceX96Range,BalanceDelta tokenAmounts,
    function (uint160,SqrtPriceX96Range memory,BalanceDelta) returns(Liquidity memory) liquidity,
    function (uint160,SqrtPriceX96Range memory,BalanceDelta) returns(uint256) multiplier
) returns(uint256){
    Liquidity memory _liquidity = entryLiquidity(
        sqrtPriceX96,
        sqrtPriceX96Range,
        tokenAmounts
    );
    uint256 _multiplier = multiplier(
        sqrtPriceX96,
        sqrtPriceX96Range,
        tokenAmounts
    );

    if (sqrtPriceX96 <= sqrtPriceX96Range.low){
        return uint256(_liquidity.liquidity0*_multiplier*1e18);
    }
    if (sqrtPriceX96 > sqrtPriceX96Range.low && sqrtPriceX96 < sqrtPriceX96Range.up){
        return uint256(_liquidity.liquidity0*_multiplier*1e18);
    }

    if (sqrtPriceX96 > sqrtPriceX96Range.up){
        return FullMath.mulDiv(1e18, _liquidity.liquidity1, _multiplier);
    }

}

function liquidity(
    uint160 sqrtPriceX96,SqrtPriceX96Range memory sqrtPriceX96Range,BalanceDelta tokenAmounts
) returns(Liquidity memory){}

function value(
    function(uint160,SqrtPriceX96Range memory,BalanceDelta) returns(Liquidity memory) position
) returns(uint256){}





