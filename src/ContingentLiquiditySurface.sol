//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@uniswap/v4-core/src/types/Currency.sol";
import "@uniswap/v4-core/src/types/PoolId.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";
import "@uniswap/v4-core/src/libraries/StateLibrary.sol";
import "@uniswap/v4-core/src/libraries/TickBitmap.sol";
import "@bunni-v2/src/ldf/LibGeometricDistribution.sol" as CallExposureSurfaceMod;

bytes32 constant STORAGE_SLOT = keccak256("contingentLiquiditySurface");

struct ContingentLiquiditySurfaceStorage{
    PoolKey contingentPair;
    IPoolManager settlementEngine;
    bytes32 optionSupplyState; // equivalent to the ldfParams
}

function getStorage() pure returns(ContingentLiquiditySurfaceStorage storage $){
    bytes32 _position = STORAGE_SLOT;
    assembly{
        $.slot := _position
    }        
}

function settlementEngine() view returns(IPoolManager){
    ContingentLiquiditySurfaceStorage storage $ = getStorage();
    return $.settlementEngine;
}

function contingentPair() view returns(PoolKey memory){
    ContingentLiquiditySurfaceStorage storage $ = getStorage();
    return $.contingentPair;
}

function rawOptionSupplyState() view returns(bytes32){
    ContingentLiquiditySurfaceStorage storage $ = getStorage();
    return $.optionSupplyState;
}


// TODO: This is reference only
function updateReferenceSpotTick(int24 updatedReferenceSpotTick) {
       ContingentLiquiditySurfaceStorage storage $ = getStorage();
       bytes32 currentRawOptionSupplyState =  rawOptionSupplyState();
       bytes32 updatedRawOptionSupplyState;
       assembly{
        // -> Mask the most right 32 bits = > 8 bytes
        // write the updatedReference there is signed
        updatedRawOptionSupplyState := or(shl(currentRawOptionSupplyState, 0x08),updatedReferenceSpotTick) 
       }
       $.optionSupplyState = updatedRawOptionSupplyState; 
       
}

function referenceSpotTick() view returns(int24){
    int24(uint24(bytes3(rawOptionSupplyState()<< 8)));    
}


function strikeGrid() view returns(int24){
    return contingentPair().tickSpacing;
}

function underlying() view returns(IERC20){
    return IERC20(Currency.unwrap(contingentPair().currency0));
}

function numeraire() view returns(IERC20){
    return IERC20(Currency.unwrap(contingentPair().currency1));
}

function spotSqrtPriceX96() view returns(uint160){
   (uint160 _sqrtPriceX96,int24 eval1,uint24 eval2,uint24 eval3) = StateLibrary.getSlot0(settlementEngine(),PoolIdLibrary.toId(contingentPair()));
   return _sqrtPriceX96;  
}

function currentStrikeIndex() view returns(int24){
   (uint160 _sqrtPriceX96,int24 value,uint24 eval2,uint24 eval3) = StateLibrary.getSlot0(settlementEngine(),PoolIdLibrary.toId(contingentPair()));
    return value;
}

function strikeIndex(int24 index) returns (int24) {
    int24 spacing = strikeGrid();
    int24 remainder = index % spacing;
    if (remainder >= spacing / 2) {
        return index + (spacing - remainder);
    }
    return index - remainder;
}

function strikeIndices(int24 targetIndex)
    returns (int24[] memory indices)
{
    int24 spot = currentStrikeIndex();
    int24 grid = strikeGrid();
    
    if (targetIndex == spot) { return new int24[](0);}

    int24 step = targetIndex > spot ? grid : -grid;

    int24 distance = targetIndex > spot
        ? targetIndex - spot
        : spot - targetIndex;

    uint256 count = uint256(int256(distance / grid));

    indices = new int24[](count);

    int24 index = spot;
    for (uint256 i = 0; i < count; i++) {
        index += step; 
        indices[i] = strikeIndex(index);
    }
}




