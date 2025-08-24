// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {IReactive} from "@reactive-network/interfaces/IReactive.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {AbstractPausableReactive} from "@reactive-network/abstract-base/AbstractPausableReactive.sol";
import {PoolId} from "@uniswap/v4-core/src/types/PoolId.sol";
import {EnumerableMap} from "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {SafeCast} from "@uniswap/v4-core/src/libraries/SafeCast.sol";
import {ILPHub} from "./interfaces/ILPHub.sol";

contract VolumeLens is IReactive, AbstractPausableReactive{
    using SafeCast for int256;
    using BalanceDeltaLibrary for BalanceDelta;
    // The keys are the blockNumbers and the values are
    // the cummulated volume
    using EnumerableMap for EnumerableMap.UintToUintMap;

    uint256 private constant UNISWAP_V4_SWAP_TOPIC_0 = 0xe5db519648e2c64b9f9604e8cd084525cf5289e470303079196ad152995bf46c;
    // keccak256("Initialized(uint64)")
    uint256 private constant INITIALIZE_TOPIC_0 = 0xc7f505b2f371ae2175ee4913f4499e1f2633a7b5936321eed1cdaeb6115181d2;
    // TODO: This is to be modified on production to account for
    // gas-budget constrains ...
    uint64 private constant CALLBACK_GAS_LIMIT = 1000000;
    PoolId private immutable POOL_ID;
    
    struct SwapData{
        // slot 1
        int128 amount0;
        int128 amount1;
        // slot 2  // 
        uint160 sqrtPriceX96;
        // slot 3
        uint128 liquidity;
        // slot 4 firts 24 bits
        int24 tick;
        // slot 4 24 to 48 bits
        uint24 fee;
    }


    EnumerableMap.UintToUintMap poolLpMetrics;
    ILPHub lpHub;
    IPoolManager poolManager;
    uint256 uniswapV4ChainId;

    uint256 lastBlock;
    

    // TODO: We can have theconstuctor receive arburtray bytes athat gover the susbcriptions

    constructor(
        ILPHub _lpHub,
        PoolId id,
        IPoolManager _poolManager,
        uint256 _uniswapV4ChainId
    ){

        paused = false;
        POOL_ID = id;
        lpHub = _lpHub;
        poolManager = _poolManager;
        uniswapV4ChainId = _uniswapV4ChainId;


        if (!vm) {
            service.subscribe(
                uniswapV4ChainId,
                address(_poolManager),
                UNISWAP_V4_SWAP_TOPIC_0,
                REACTIVE_IGNORE,
                REACTIVE_IGNORE,
                REACTIVE_IGNORE
            );
            service.subscribe(
                uniswapV4ChainId,
                address(_lpHub),
                INITIALIZE_TOPIC_0,
                REACTIVE_IGNORE,
                REACTIVE_IGNORE,
                REACTIVE_IGNORE
            );
        }      
    }

    function getPausableSubscriptions() internal view override returns (Subscription[] memory) {
        Subscription[] memory result = new Subscription[](1);
        result[0] = Subscription(
            uniswapV4ChainId,
            address(poolManager),
            UNISWAP_V4_SWAP_TOPIC_0,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        return result;
    }


    function react(
        LogRecord calldata log
    ) external vmOnly {
        if (
            log.topic_0 == UNISWAP_V4_SWAP_TOPIC_0
        &&
            log.topic_1 == uint256(PoolId.unwrap(POOL_ID))
        )
        {
            uint256 currentBlock = log.block_number;
            uint256 tradingVolumeOnBlock;
            SwapData memory swapData = abi.decode(
                log.data,
                ( SwapData)
            );
            {
                uint256 tradingVolumeOnSwap = uint256(
                    BalanceDelta.unwrap(
                        toBalanceDelta(
                            swapData.amount0,
                            swapData.amount1
                        )
                    )
                );
                if (currentBlock == lastBlock){
                
                    tradingVolumeOnBlock += tradingVolumeOnSwap;    
                
                } else if (
                
                    tradingVolumeOnBlock != uint256(0x00)
                
                )
                {
                    // TODO: This needs to be improved ...
                    // one can have identical tradingVolume= values
                    //on different blocks and this should be valid
                    // which is not valid here
                
                    poolLpMetrics.set(
                        log.block_number,
                        tradingVolumeOnBlock
                    );
                
                    tradingVolumeOnBlock = tradingVolumeOnSwap;    
                }

                if (
                    poolLpMetrics.length() != uint256(0x00)
                ) 
                {
                    uint256 len = poolLpMetrics.length();
                    
                    uint256[] memory keys = new uint256[](len);
                    uint256[] memory values = new uint256[](len);
                    
                    for (uint256 i = 0; i < len; i++) {
                        (keys[i], values[i]) = poolLpMetrics.at(i);
                    }

                    bytes memory payload = abi.encodeCall(
                        ILPHub.calculateFeesFromVolume,
                        (
                            abi.encode(
                                keys, 
                                values
                            )
                        )
                    );

                    emit Callback(
                        log.chain_id, 
                        address(lpHub),
                        CALLBACK_GAS_LIMIT,
                        payload
                    );
                }
                
            }


            lastBlock = log.block_number;




            // NOTE: Calculate the trading volume per-block


        }
        
        
    }



}



