# //Liquidity provider adds 100 USDC and 100 USDT
#     // within a price range of [0.5,2] considering
#     // a tick spacing of 1
#     //He wants his liquidiyt to be gaussian centered
#     // around 1 USDC/USDT and with a standard deviation
#     // of 0.5 USDC/USDT
#     // We have
#     //   Price Interval:[0.5,2] --> Tick Range: [-6932, 6931]
#     //   tick spacing : 1

"""
Uniswap v3 Concentrated Liquidity Math and Utilities
Implements core formula conversions and calculations as described in the Uniswap v3 whitepaper.
"""
import math
from typing import Tuple

#  //   Price Interval:[0.5,2] --> Tick Range: [-6932, 6931]
# 1. Having a price I can get the corresponding tick, and alternatively having a tick I can get the
# corresponding price and price square root.
# This all considers the BASE of 1.0001, and the bounds of ticks which are [-887272, 887272]
# TODO:
#    1. Have constrains on the ticks given so they do not exceed the bounds
#    2. Implement all possible tests fro this class
class TickMath:
    """
    Utilities for converting between price and tick, as per Uniswap v3 whitepaper.
    """
    MIN_TICK = -887272
    MAX_TICK = 887272
    BASE = 1.0001
    @staticmethod
    def fromPriceToTick(price: float) -> int:
        """Converts a price to the corresponding tick, enforcing tick bounds."""
        tick = math.log(price) / math.log(TickMath.BASE)
        tick = int(round(tick))
        # Enforce tick bounds

        if tick < TickMath.MIN_TICK:
            tick = TickMath.MIN_TICK
        elif tick > TickMath.MAX_TICK:
            tick = TickMath.MAX_TICK
        return tick

    @staticmethod
    def fromTickToPrice(tick: int) -> float:
        """Converts a tick to the corresponding price, enforcing tick bounds."""
        if tick < TickMath.MIN_TICK:
            tick = TickMath.MIN_TICK
        elif tick > TickMath.MAX_TICK:
            tick = TickMath.MAX_TICK
        return TickMath.BASE ** tick

    @staticmethod
    def fromTickToSqrtPrice(tick: int) -> float:
        """Converts a tick to the corresponding square root price, enforcing tick bounds."""
        if tick < TickMath.MIN_TICK:
            tick = TickMath.MIN_TICK
        elif tick > TickMath.MAX_TICK:
            tick = TickMath.MAX_TICK
        return TickMath.BASE ** (tick / 2)



#  //   Price Interval:[0.5,2] --> Tick Range: [-6932, 6931]
class TickRangeMath:

    """
    Utilities for calculating tick ranges based on price intervals.
    """
    @staticmethod
    def fromPriceIntervalToTickRange(price_min: float, price_max: float) -> Tuple[int, int]:
        """Calculates the tick range for a given price interval."""
        tick_min = TickMath.fromPriceToTick(price_min)
        tick_max = TickMath.fromPriceToTick(price_max)
        return tick_min, tick_max
    


# struct ModifyLiquidityParams {
#     // the lower and upper tick of the position
#     int24 tickLower;
#     int24 tickUpper;
#     // how to modify the liquidity
#     int256 liquidityDelta;
#     // a value to set if you want unique liquidity positions at the same range
#     bytes32 salt;
# }



