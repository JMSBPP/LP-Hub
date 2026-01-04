// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@uniswap/v4-periphery/src/lens/V4Quoter.sol";
import "@uniswap/v4-core/src/libraries/StateLibrary.sol";
import {SqrtPriceLibrary} from "@uniswap-foundation/libraries/SqrtPriceLibrary.sol";
import {PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {SwapMath} from "@unsiwap/v4-core/src/libraries/SwapMath.sol";
import "@uniswap/v4-core/src/libraries/TickMath.sol";
import {LiquidityMath} from "@uniswap/v4-core/src/libraries/LiquidityMath.sol";

bytes32 constant STORAGE_SLOT = keccak256("quote-builder");

struct QuoteBuilderStorage{
    V4Quoter v4Quoter;
}

function getStorage() pure returns(QuoteBuilderStorage storage $){
    bytes32 _position = STORAGE_SLOT;
    assembly{
        $.slot := _position
    }
}

function quoter() view returns(V4Quoter){
    QuoteBuilderStorage storage $ = getStorage();
    return $.v4Quoter;
}

function poolManager() view returns(IPoolManager){
    return quoter().poolManager();
}

function getQuotesToPrice(V4Quoter.QuoteExactParams memory) view returns(uint160 sqrtPrice){}

function getPathToPrice(PoolKey memory poolKey, uint160 targetSqrtPriceX96) view returns(V4Quoter.QuoteExactSingleParams[] memory){
     PoolId poolId = PoolIdLibrary.toId(poolKey);
    (uint160 sqrtPriceX96,uint24 tick,,uint24 lpFee) = StateLibrary.getSlot0(poolManager(),poolId);
     (uint128 tickLiquidity,) = StateLibrary.getTickLiquidity(poolManager(),poolId,tick);
     uint160 sqrtPriceX96Delta =  SqrtPriceLibrary.absDifferenceX96(sqrtPriceX96,targetSqrtPriceX96);
     uint256 oneTokenUnit = 10**IERC20(Currency.unwrap(poolKey.currency1)).decimals();


     uint256 amountToGetThere = oneTokenUnit*sqrtPriceX96Delta;
     uint160 sqrtPriceX96NextPrice = targetSqrtPriceX96;
     uint24 nextTick =  TickMath.getTickAtSqrtPrice(targetSqrtPriceX96);
     (uint128 liquidityOnNextTick,)= StateLibrary.getTickLiquidity(poolManager(),poolId,nextTick);
     V4Quoter.QuoteExactSingleParams[] memory path = new V4Quoter.QuoteExactSingleParams[](amountToGetThere/oneTokenUnit); 
     
     while (amountToGetThere >= 0){

        (sqrtPriceX96NextPrice, uint256 amountIn, uint256 amountOut,) = SwapMath.computeSwapStep(
            sqrtPriceX96,
            sqrtPriceX96NextPrice,
            LiquidityMath.addDelta(liquidityOnNextTick,tickLiquidity),
            amountToGetThere,
            lpFee
        );

        path.push(
            V4Quoter.QuoteExactSingleParams(poolKey,true,amountIn, bytes(""))            
        );


        amountToGetThere-= oneTokenUnit;
        uint24 nextTick =  TickMath.getTickAtSqrtPrice(sqrtPriceX96NextPrice);
       (uint128 liquidityOnNextTick,)= StateLibrary.getTickLiquidity(poolManager(),poolId,nextTick);

     }

     return path;

}