#=========INTERFACES AND ABSTRACT CLASSES===========
from abc import ABC, abstractmethod
from enum import Enum
class Distribution(Enum):

    GAUSSIAN = 1
    UNIFORM = 2
    EXPONENTIAL = 3
    LOGNORMAL = 4
    BINOMIAL = 5
    POISSON = 6
    # Add more distributions as needed


class IntervalToDistributionStdStrategy(ABC):

    def __init__(self, distribution: Distribution):
        self.distribution = distribution
    
    @abstractmethod
    def calculateFixedStandardDeviation(self, size: int, meanPrice: float, interval: tuple[float, float]) ->list[float]:
        '''
        Returns a random sample from the distribution given the mean price and interval.
        This method should be overridden by subclasses.
        '''
        pass
    @abstractmethod
    def generateRandomSample(self, size: int, meanPrice: float, interval: tuple[float, float]) -> list[float]:
        '''
        Generates a random sample of prices based on the specified distribution.
        This method should be overridden by subclasses.
        '''
        pass
    @abstractmethod
    def generateLiquidityDensity(self, sampleSize: int, meanPrice: float, interval: tuple[float, float]) -> list[float]:
        '''
        Generates a liquidity density function based on the specified distribution.
        This method should be overridden by subclasses.
        '''
        pass
    @abstractmethod
    def generateCummulativeLiquidity(self, priceSubInterval: tuple[float, float]) -> float:
        '''
        Generates the cumulative liquidity for a given price sub-interval.
        This method should be overridden by subclasses.
        '''
        pass
