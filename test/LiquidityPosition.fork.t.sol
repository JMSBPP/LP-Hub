// // // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// import "./ForkUtils.sol";
// import {Test, console2} from "forge-std/Test.sol";
// import {IERC20} from "forge-std/interfaces/IERC20.sol";
// import {PosmTestSetup} from "@uniswap/v4-periphery/test/shared/PosmTestSetup.sol";
// import {IPositionManager} from "@uniswap/v4-periphery/src/interfaces/IPositionManager.sol";
// import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
// import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
// import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";
// import "@uniswap/v4-core/src/types/PoolId.sol";
// import "@uniswap-foundation/libraries/SqrtPriceLibrary.sol";
// import {Constants} from "@uniswap/v4-core/test/utils/Constants.sol";
// import {IStateView} from "@uniswap/v4-periphery/src/interfaces/IStateView.sol";
// import {IWETH9} from "@uniswap/v4-periphery/src/interfaces/external/IWETH9.sol";
// import {IAllowanceTransfer} from "permit2/src/interfaces/IAllowanceTransfer.sol";
// import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";
// import {PositionConfig} from "@uniswap/v4-periphery/test/shared/PositionConfig.sol";
// import {LiquidityAmounts} from "@uniswap/v4-core/test/utils/LiquidityAmounts.sol";
// import {FullMath} from "@uniswap/v4-core/src/libraries/FullMath.sol";
// import "../src/LiquidityPosition.sol";
// import "@uniswap/v4-core/src/types/BalanceDelta.sol";
// import {MockERC20} from "solady/test/utils/mocks/MockERC20.sol";

// contract LiquidityPositionForkTest is Test, PosmTestSetup{
//   \  
//     address poolDeployer = makeAddr("poolDeployer");
//     address liquidityProvider = makeAddr("liquidityProvider");
//     address trader = makeAddr("trader");

//     IERC20 USDC;
//     IWETH9 WETH;
//     PoolId id;
//     IStateView lens;

//     function setUp() public {
//         vm.createSelectFork(vm.rpcUrl("https://eth-mainnet.g.alchemy.com/v2/vmIxax9_LpniE6IH5M_xRokN4YSASHa6"),21_900_000);
    
//         manager = IPoolManager(EthereumMainnet.POOL_MANAGER);
//         lpm = IPositionManager(EthereumMainnet.POSITION_MANAGER);
//         lens = IStateView(EthereumMainnet.STATE_VIEW);
//         permit2 = IAllowanceTransfer(PERMIT2_ADDRESS);

//         USDC = IERC20(EthereumMainnet.USDC);
//         WETH = IWETH9(EthereumMainnet.WETH);

//         deal(address(USDC), poolDeployer, 40000*1e18);
//         vm.deal(poolDeployer, 10*1e18);
        

//         vm.startPrank(poolDeployer);

//         WETH.deposit{value: 10*1e18}();
//         (currency0, currency1) = (
//             Currency.wrap(EthereumMainnet.USDC),
//             Currency.wrap(EthereumMainnet.WETH)
//         );

//         approvePosm();
//         (key,id) = initPool(
//                 currency0,
//                 currency1,
//                 IHooks(address(0x00)),
//                 Constants.FEE_MEDIUM,
//                 SqrtPriceLibrary.exchangeRateToSqrtPriceX96(
//                     25*1e13
//                 )
//             );
//         console2.log("Currency 0:", Currency.unwrap(key.currency0));
//         console2.log("Currency 1:", Currency.unwrap(key.currency1));        
//         vm.stopPrank();

//     }
//     // 4 -> 1/4 = 0.25
//     // ==> 4000 -> 1/4000 = 0.00025
    
//     // ==> 4499 -> 1/4499.7603 = 0.00022
//     // ==> 1499 -> 1/1499 = 0.00066
//     function test__fork__mockScenario() public {
//     //==============PRE-CONDITIONS=======================
//     // Create the pool
//     vm.startPrank(poolDeployer);
//     PoolKey memory poolKey = PoolKey(Currency.wrap(address(new MockERC20("TST","TST", 8))),Currency.wrap(address(new MockERC20("TST2","TST2", 8))),Constants.FEE_HIGH,int24(60),IHooks(address(0x00)));
//     (int24 tickPrice2_1) = lpm.initializePool(
//         PoolKey(
//             Currency.wrap(address(new MockERC20("TST","TST", 8))),
//             Currency.wrap(address(new MockERC20("TST2","TST2", 8))),
//             Constants.FEE_HIGH,
//             int24(60),
//             IHooks(address(0x00))    
//         ),
//         Constants.SQRT_PRICE_2_1
//                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      );

//     vm.stopPrank();
//     uint128 poolLiquidity = lens.getLiquidity(PoolIdLibrary.toId(poolKey));
//     console2.log("L:",poolLiquidity);
    
//     vm.startBroadcast(liquidityProvider);
//     (uint160 currentSqrtPriceX96, int24 currentTick, uint24 protocolFee, uint24 lpFee) = lens.getSlot0(PoolIdLibrary.toId(poolKey));


//     uint128 initialLiquidity = LiquidityAmounts.getLiquidityForAmounts(
//         currentSqrtPriceX96,
//         SqrtPriceLibrary.exchangeRateToSqrtPriceX96(18e17),
//         SqrtPriceLibrary.exchangeRateToSqrtPriceX96(22e17),
//         20e18,
//         40e18
//     );
//     console2.log("L0:",initialLiquidity);


    
//     } 
//     function test__fork__liquidityPosition() public {
//         //==========PRE-CONDITIONS===================
//         (uint160 sqrtPriceX96, int24 tick, uint24 protocolFee, uint24 lpFee) = lens.getSlot0(id);
//         console2.log("Current Price:",sqrtPriceX96);

//         console2.log("Current Tick:", tick);
//         console2.log(sqrtPriceX96);
//         (uint160 lowSqrtPriceX96,uint160 upSqrtPriceX96) = (
//             SqrtPriceLibrary.exchangeRateToSqrtPriceX96(
//                 66*1e13
//             ),
//             SqrtPriceLibrary.exchangeRateToSqrtPriceX96(
//                 22*1e13
//             )

//         );

//         console2.log("Low Price:",lowSqrtPriceX96);
//         console2.log("Up Price:", upSqrtPriceX96);
//         (int24 lowTick, int24 upTick) = (
//             TickMath.getTickAtSqrtPrice(lowSqrtPriceX96)
//             ,
//             TickMath.getTickAtSqrtPrice(upSqrtPriceX96)
//         );
//         console2.log("Lower Tick:", lowTick);
//         console2.log("Upper Tick:", upTick);
//         uint256 amount1 = 1e18;
//         console2.log("x1:", amount1);
//         Liquidity memory liquidity = entryLiquidity(
//             sqrtPriceX96,
//             SqrtPriceX96Range(lowSqrtPriceX96,upSqrtPriceX96),
//             toBalanceDelta(0, int128(uint128(amount1)))
//         );
//         console2.log("L:",liquidity.liquidity);
//         console2.log("Lx:", liquidity.liquidity0);
//         console2.log("Ly", liquidity.liquidity1);
//         // Where is the 1106.35
//         // console2.log("y0:",amount0);
        
//      }

// }