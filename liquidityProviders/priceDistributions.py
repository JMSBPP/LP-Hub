# Given a sample of price values over the interval [P-e, P+e] where the mean of this values are P
# I give the interval and the mean and a flag indicating the desnsity function of the Price .
# I want to output the associated standard deviation of the gaussian distribution
#=========INTERFACES AND ABSTRACT CLASSES===========
from interfaces.IntervalToDistributionStdStrategy import IntervalToDistributionStdStrategy, Distribution

#=========DATA STRUCTURES============

from numpy import ndarray as Vector
from pandas import Interval

#=======MATH TYPES =========
import math
import random
from scipy.stats import norm as gaussian

        

# TODO: Replace Interval for a more suitable data structure for price intervals
class IntervalToDistribution:

    def __init__(self, meanPrice: float, interval: Interval, distribution: Distribution):
        self.meanPrice = meanPrice
        self.interval = interval
        self.distribution = distribution
        self.strategy = IntervalToDistributionStdStrategy(distribution)
        self.stdDev = None  # Standard deviation will be set later and it is optional

    def setFixedStandardDeviation(self, sampleSize: int):
        self.stdDev = self.strategy.calculateFixedStandardDeviation(sampleSize, self.meanPrice, self.interval)

    def generateRandomSample(self, sampleSize: int) -> list[float]:
        '''
        Generates a random sample of prices of size (sampleSize) based on the specified distribution.
        '''
        if self.stdDev is None:
            raise ValueError("Standard deviation must be set before generating a random sample.")
        
        return self.strategy.generateRandomSample(sampleSize, self.meanPrice, self.interval)


class GaussianDistribution(IntervalToDistributionStdStrategy):
    def __init__(self):
        super().__init__(Distribution.GAUSSIAN)
    def calculateFixedStandardDeviation(self, size: int, meanPrice: float, interval: Interval) -> float:
        std_dev = (interval[1] - interval[0]) / 6
        return std_dev
    def generateRandomSample(self, size: int, meanPrice: float, interval: Interval) -> list[float]:
        std_dev = self.calculateFixedStandardDeviation(size, meanPrice, interval)
        return [random.gauss(meanPrice, std_dev) for _ in range(size)]
    def generateLiquidityDensity(self, sampleSize: int, meanPrice: float, interval: Interval) -> list[float]:
        priceValues = self.generateRandomSample(sampleSize, meanPrice, interval)
        std_dev = self.calculateFixedStandardDeviation(sampleSize, meanPrice, interval)
        density = gaussian.pdf(priceValues, loc=meanPrice, scale=std_dev)
        return density.tolist()
    def generateCummulativeLiquidity(self, priceSubInterval: Interval) -> float:
        ## check that the price sub-interval is within the main interval
        if priceSubInterval[0] < self.interval[0] or priceSubInterval[1] > self.interval[1]:
            raise ValueError("Price sub-interval must be within the main interval.")
        cummulativeLiquidityWithinSubInterval = gaussian.cdf(priceSubInterval)
        return  cummulativeLiquidityWithinSubInterval
    
class liquidityDensityFunction(IntervalToDistribution):
    def __init__(self,meanPrice: float, interval: Interval, priceBelief: Distribution):
        super().__init__(meanPrice, interval, priceBelief)
        self.randomSample = None  # Density function will be set later
        self.liquidityDensity = None
    def setRandomSample(self, sampleSize: int):
        """
        Generates a random sample of prices based on the specified distribution.
        """
        self.randomSample = self.strategy.generateRandomSample(sampleSize)
    def setLiquidityDensity(self, sampleSize: int) -> list[float]:
        """
        Sets the liquidity density function based on the random sample.
        """
        self.liquidityDensity = self.strategy.generateLiquidityDensity(sampleSize, self.meanPrice, self.interval)
    # Given an price-sub interval of the interval given
    ## I want to calculate the gross liquidity density allocated to this sub-interval
    # This is we are defining a mapping from price sub-intervals to liquidity density values.
    # I think this is equivalent to finding the cummulative distrbution over a price sub-interval
    

 
    ## Based on the random sample, we can calculate the liquiduty density function


