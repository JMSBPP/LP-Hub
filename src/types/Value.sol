// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {PositionManager} from "@uniswap/v4-periphery/src/PositionManager.sol";
import "@uniswap/v4-periphery/src/libraries/PositionInfoLibrary.sol";
import "@uniswap/v4-core/src/libraries/StateLibrary.sol";
import {PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import "@uniswap/v4-core/src/libraries/TickMath.sol";
import {FullMath} from "@uniswap/v4-core/src/libraries/FullMath.sol";
import {SqrtPriceLibrary} from "@uniswap-foundation/libraries/SqrtPriceLibrary.sol";
import {LiquidityAmounts} from "@uniswap/v4-core/test/utils/LiquidityAmounts.sol";
// \sq P = 1.0001^(i/2)
// 
bytes32 constant STORAGE_SLOT = keccak256("lp-portafolio-manager");

struct LPPortafolioManager{
    PositionManager positionManager;
}

function getStorage() pure returns(LPPortafolioManager storage $){
    bytes32 _position = STORAGE_SLOT;
    assembly{
        $.slot := _position
    }
}

function positionManager() view returns(PositionManager){
    LPPortafolioManager storage $ = getStorage();
    return $.positionManager;
}

function poolManager() view returns(IPoolManager){
    return positionManager().poolManager();
}


function positionValue(uint256 tokenId) view returns(uint256){
    (PoolKey memory poolKey, PositionInfo positionInfo ) = positionManager().getPoolAndPositionInfo(tokenId);
     PoolId poolId = PoolIdLibrary.toId(poolKey);
    (int24 tickLower, int24 tickUpper) = (PositionInfoLibrary.tickLower(positionInfo),PositionInfoLibrary.tickUpper(positionInfo));
    (uint160 sqrtPriceX96,,,) = StateLibrary.getSlot0(poolManager(),poolId);
    (uint160 sqrtPriceX96Low, uint160 sqrtPriceX96Up) = (TickMath.getSqrtPriceAtTick(tickLower),TickMath.getSqrtPriceAtTick(tickUpper)); 
    uint128 positionLiquidity = positionManager().getPositionLiquidity(tokenId);
    if (sqrtPriceX96 >= sqrtPriceX96Low && sqrtPriceX96 <= sqrtPriceX96Up){
        return uint256(positionLiquidity)*(2*SqrtPriceLibrary.absDifferenceX96(sqrtPriceX96,sqrtPriceX96Low) - SqrtPriceLibrary.divX96(sqrtPriceX96, sqrtPriceX96Up) + sqrtPriceX96Low); 
    }
}

function putOptionSellerPayoff(uint256 tokenId) view returns(uint256){
    (PoolKey memory poolKey, PositionInfo positionInfo ) = positionManager().getPoolAndPositionInfo(tokenId);
     PoolId poolId = PoolIdLibrary.toId(poolKey);
     int24 tickStrike = PositionInfoLibrary.tickLower(positionInfo);
     uint160 sqrtStrikeX96 =  TickMath.getSqrtPriceAtTick(tickStrike);
     (uint160 sqrtPriceX96,,,) = StateLibrary.getSlot0(poolManager(),poolId);
     uint128 positionLiquidity = positionManager().getPositionLiquidity(tokenId);

     uint256 notional = LiquidityAmounts.getAmount0ForLiquidity(sqrtPriceX96, sqrtStrikeX96, positionLiquidity);
     if (sqrtPriceX96 <= sqrtStrikeX96) return SqrtPriceLibrary.absDifferenceX96(sqrtStrikeX96, sqrtPriceX96)*notional;
}



