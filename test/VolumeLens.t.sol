// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;


import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {VolumeLens} from "../src/VolumeLens.sol";
import {LPHub} from "../src/LPHub.sol";
import {Deployers} from "@uniswap/v4-core/test/utils/Deployers.sol";
import {
    Currency,
    CurrencyLibrary
} from "@uniswap/v4-core/src/types/Currency.sol";

import {Test, console2} from "forge-std/Test.sol";
import {ISystemContract} from "@reactive-network/interfaces/ISystemContract.sol";
import {Constants} from "@uniswap/v4-core/test/utils/Constants.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {PoolKey,PoolId, PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
contract VolumeLensTest is Test, Deployers {
    using CurrencyLibrary for Currency;
    using PoolIdLibrary for PoolKey;


    address constant REACTIVE_SYSTEM_CONTRACT=0x0000000000000000000000000000000000fffFfF;
    address payable constant SEPOLIA_CALLBACK_PROXY_ADDRESS=payable(0xc9f36411C9897e7F959D99ffca2a0Ba7ee0D7bDA);

    LPHub lpHub;
    VolumeLens volumeLens;
    ISystemContract sepoliaSender;

    uint256 ethereumSepoliaForkId;
    uint256 reactiveSepoliaForkId;

    function setUp() public 
    {   

        reactiveSepoliaForkId = vm.createFork("reactive-testnet");
        ethereumSepoliaForkId = vm.createSelectFork("sepolia");
        {            
            deployFreshManagerAndRouters();
            // NOTE: Replace the poolManager with the actual
            // poolManager on sepolia
            
            manager = IPoolManager(
                0xE03A1074c86CFeDd5C142C4F04F1a1536e203543
            );

            sepoliaSender  = ISystemContract(
                SEPOLIA_CALLBACK_PROXY_ADDRESS
            );

            lpHub = new LPHub(
                SEPOLIA_CALLBACK_PROXY_ADDRESS,
                manager
            );
            (currency0, currency1) = deployMintAndApprove2Currencies();
            (key, )= initPool(
                currency0,
                currency1,
                IHooks(address(0x00)),
                Constants.FEE_MEDIUM,
                SQRT_PRICE_1_2
            ); 
        }

        
    }

    function test__ShouldSubscribeToSwap() external{
        vm.selectFork(reactiveSepoliaForkId);
        
        {
            volumeLens = new VolumeLens(
                lpHub,
                key.toId(),
                manager,
                uint256(0xaa36a7)
            );
        }
    }

    

    
}


