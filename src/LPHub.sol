// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;


import {ILPHub} from "./interfaces/ILPHub.sol";
import {AbstractCallback} from "@reactive-network/abstract-base/AbstractCallback.sol";
import {EnumerableMap} from "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {StateLibrary} from "@uniswap/v4-core/src/libraries/StateLibrary.sol";
import {ImmutableState} from "@uniswap/v4-periphery/src/base/ImmutableState.sol";

contract LPHub is ILPHub, AbstractCallback, ImmutableState{
    using StateLibrary for IPoolManager;
    using EnumerableMap for EnumerableMap.UintToUintMap; 
    
    
    // NOTE: This is only for debugging
    event Received(bytes);
    constructor(
        address _callback_sender,
        IPoolManager _manager
    ) ImmutableState(_manager) AbstractCallback(_callback_sender){}
    
    function calculateFeesFromVolume(
        bytes memory encodedPoolLpMetrics
    ) external returns(uint256){
        emit Received(encodedPoolLpMetrics);
        return 1;
    }
    

}