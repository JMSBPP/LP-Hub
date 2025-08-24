# Uniswap Reactive Network - APR Calculator

## Overview

The **Uniswap Reactive Network** is a Solidity-based, event-driven system that monitors Uniswap V3 events in real-time and calculates APR (Annual Percentage Rate) for liquidity positions. This implementation demonstrates how to build reactive DeFi applications using smart contracts.

## 🎯 What This Solves

The traditional approach to calculating Uniswap APR involves:
- ❌ **Off-chain polling** of contract data
- ❌ **Batch processing** of historical events
- ❌ **Delayed updates** due to indexing lag
- ❌ **Centralized dependencies** on external APIs

The Reactive Network approach provides:
- ✅ **Real-time event processing** on-chain
- ✅ **Immediate APR calculations** when events occur
- ✅ **Decentralized architecture** with no external dependencies
- ✅ **Efficient gas usage** through event queuing and batching

## 🏗️ Architecture

### Core Components

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Uniswap V3    │    │  Reactive        │    │   External      │
│   Pool Events   │───▶│  Network         │───▶│   Systems       │
│                 │    │  Contract        │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

### Data Flow

1. **Event Detection**: Uniswap V3 pools emit events (Swap, Collect, etc.)
2. **Event Queuing**: Events are queued in the reactive network contract
3. **Event Processing**: Queued events are processed to update metrics
4. **APR Calculation**: Real-time APR calculations based on updated metrics
5. **Event Emission**: Results are emitted as events for external consumption

## 📊 Key Features

### 1. **Real-Time Event Processing**
- Monitors Uniswap V3 events (Swap, Collect, Mint, Burn)
- Queues events for efficient processing
- Updates pool metrics immediately

### 2. **Automatic APR Calculation**
- Calculates APR for tracked positions
- Updates calculations when pool metrics change
- Maintains historical APR data

### 3. **Efficient Data Management**
- Event queuing system to handle high-frequency updates
- Configurable update intervals to prevent spam
- Automatic cleanup of processed events

### 4. **Flexible Configuration**
- Configurable fee rates for different pools
- Adjustable update intervals and queue sizes
- Support for multiple pools and positions

## 🔧 Smart Contract Functions

### Core Functions

| Function | Description | Access |
|----------|-------------|---------|
| `addPool(address, uint256)` | Add a new pool to track | Owner only |
| `addPosition(tokenId, owner, liquidity, tickLower, tickUpper)` | Add a new position to track | Owner only |
| `queueEvent(eventHash, poolAddress, eventData)` | Queue a new event for processing | Public |
| `processEvents(maxEvents)` | Process queued events | Public |
| `calculatePositionAPR(tokenId)` | Calculate APR for a position | Public |

### View Functions

| Function | Description | Returns |
|----------|-------------|---------|
| `getPoolMetrics(address)` | Get current pool metrics | PoolMetrics struct |
| `getPositionData(tokenId)` | Get current position data | PositionData struct |
| `getTrackedPools()` | Get all tracked pool addresses | Address array |
| `getTrackedPositions()` | Get all tracked position IDs | Uint256 array |
| `getSystemStats()` | Get system statistics | Multiple values |

## 🚀 Quick Start

### 1. **Installation**

```bash
# Clone the repository
git clone <repository-url>
cd phase1CoreLogic/implementation-guide

# Install dependencies
npm install

# Install Hardhat (if not already installed)
npm install --save-dev hardhat
```

### 2. **Configuration**

Create a `.env` file with your configuration:

```env
# Network Configuration
NETWORK_URL=https://eth-mainnet.alchemyapi.io/v2/YOUR_API_KEY
PRIVATE_KEY=your_private_key_here

# Contract Configuration
PRICE_ORACLE=0x0000000000000000000000000000000000000000
POSITION_MANAGER=0xC36442b4a4522E871399CD717aBDD847Ab11FE88

# System Parameters
MIN_UPDATE_INTERVAL=60
MAX_EVENT_QUEUE_SIZE=1000
APR_CALCULATION_WINDOW=86400
```

### 3. **Deployment**

```bash
# Compile contracts
npx hardhat compile

# Deploy to network
npx hardhat run deploy-reactive-network.js --network mainnet
```

### 4. **Setup**

```javascript
// Add pools to track
await reactiveNetwork.addPool(
  '0x8ad599c3A0ff1De082011EFDDc58f1908eb6e6D8b', // USDC/WETH 0.3%
  3000 // 0.3% fee rate
);

// Add positions to track
await reactiveNetwork.addPosition(
  1, // token ID
  '0xYourAddress', // owner
  ethers.utils.parseEther('1000'), // liquidity
  193000, // tick lower
  195000  // tick upper
);
```

## 📈 How APR Calculation Works

### Formula

```
APR = (Annual Fees / Position Value) × 100

Where:
- Annual Fees = Daily Fees × 365
- Daily Fees = (Pool Daily Fees × Position Share)
- Position Share = Position Liquidity / Total Pool Liquidity
- Position Value = Position Liquidity in USD
```

### Implementation

```solidity
function _calculateAPR(
    PositionData storage position,
    PoolMetrics storage poolMetrics,
    address poolAddress
) internal view returns (uint256 apr) {
    // 1. Calculate position's share of pool
    uint256 positionShare = _calculatePositionShare(position, poolAddress);
    
    // 2. Calculate daily fees for the position
    uint256 dailyFees = poolMetrics.totalFeesUSD
        .mul(positionShare)
        .div(aprCalculationWindow);
    
    // 3. Calculate annual fees
    uint256 annualFees = dailyFees.mul(365);
    
    // 4. Calculate position value in USD
    uint256 positionValue = _calculatePositionValue(position, poolAddress);
    
    // 5. Calculate APR in basis points
    if (positionValue > 0) {
        apr = annualFees.mul(10000).div(positionValue);
    }
    
    return apr;
}
```

## 🔄 Event Processing Workflow

### 1. **Event Detection**
```javascript
// Monitor Uniswap V3 events
poolContract.on('Swap', (sender, recipient, amount0, amount1, sqrtPriceX96, liquidity, tick) => {
    // Queue event in reactive network
    await reactiveNetwork.queueEvent(
        ethers.utils.keccak256(ethers.utils.toUtf8Bytes(`${sender}-${Date.now()}`)),
        poolAddress,
        ethers.utils.defaultAbiCoder.encode(
            ['address', 'address', 'int256', 'int256', 'uint160', 'uint128', 'int24'],
            [sender, recipient, amount0, amount1, sqrtPriceX96, liquidity, tick]
        )
    );
});
```

### 2. **Event Processing**
```javascript
// Process queued events
await reactiveNetwork.processEvents(10); // Process up to 10 events
```

### 3. **Metrics Update**
```solidity
// Events automatically update pool metrics
function _processSwapEvent(EventData storage eventData) internal {
    address poolAddress = eventData.poolAddress;
    PoolMetrics storage metrics = poolMetrics[poolAddress];
    
    // Update volume, fees, and TVL based on event data
    // ... calculation logic ...
    
    emit PoolMetricsUpdated(poolAddress, volume, fees, tvl, timestamp);
}
```

### 4. **APR Recalculation**
```javascript
// APR is automatically recalculated when metrics change
const apr = await reactiveNetwork.calculatePositionAPR(tokenId);
console.log(`New APR: ${apr / 100}%`);
```

## 🧪 Testing

### Local Testing

```bash
# Start local Hardhat network
npx hardhat node

# Deploy to local network
npx hardhat run deploy-reactive-network.js --network localhost

# Run tests
npx hardhat test
```

### Test Scenarios

1. **Event Queuing Test**
   - Queue multiple events
   - Verify queue size limits
   - Test event processing

2. **APR Calculation Test**
   - Add test pools and positions
   - Simulate trading activity
   - Verify APR calculations

3. **Performance Test**
   - Test with high event frequency
   - Verify gas efficiency
   - Test queue cleanup

## 🔒 Security Features

### Access Control
- **Owner-only functions** for critical operations
- **Pool validation** before event processing
- **Position verification** before APR calculation

### Reentrancy Protection
- **ReentrancyGuard** modifier on all external functions
- **Safe math operations** using OpenZeppelin libraries

### Input Validation
- **Address validation** for pool and position addresses
- **Parameter bounds checking** for configuration values
- **Event data validation** before processing

## 📊 Monitoring and Analytics

### System Metrics
```javascript
const stats = await reactiveNetwork.getSystemStats();
console.log(`Total Events Processed: ${stats._totalEventsProcessed}`);
console.log(`Total APR Calculations: ${stats._totalAPRCalculations}`);
console.log(`Tracked Pools: ${stats._trackedPoolsCount}`);
console.log(`Tracked Positions: ${stats._trackedPositionsCount}`);
```

### Pool Metrics
```javascript
const metrics = await reactiveNetwork.getPoolMetrics(poolAddress);
console.log(`Volume: $${ethers.utils.formatEther(metrics.totalVolumeUSD)}`);
console.log(`Fees: $${ethers.utils.formatEther(metrics.totalFeesUSD)}`);
console.log(`TVL: $${ethers.utils.formatEther(metrics.totalValueLockedUSD)}`);
```

### Position Analytics
```javascript
const position = await reactiveNetwork.getPositionData(tokenId);
console.log(`Liquidity: ${ethers.utils.formatEther(position.liquidity)}`);
console.log(`APR: ${position.lastAPR / 100}%`);
console.log(`Last Update: ${new Date(position.lastUpdateTimestamp * 1000)}`);
```

## 🚀 Production Deployment

### 1. **Network Selection**
- **Mainnet**: For production use
- **Testnet**: For testing and validation
- **Private Network**: For enterprise deployments

### 2. **Configuration Optimization**
```solidity
// Production settings
MIN_UPDATE_INTERVAL = 300;        // 5 minutes
MAX_EVENT_QUEUE_SIZE = 5000;      // 5000 events
APR_CALCULATION_WINDOW = 86400;   // 24 hours
```

### 3. **Gas Optimization**
- Use batch processing for multiple events
- Implement event filtering to reduce unnecessary processing
- Consider using Layer 2 solutions for high-frequency events

### 4. **Monitoring Setup**
- Set up event monitoring for contract events
- Implement alerting for system metrics
- Monitor gas usage and optimize accordingly

## 🔮 Future Enhancements

### 1. **Advanced APR Models**
- Impermanent loss calculation
- Fee compounding effects
- Risk-adjusted returns

### 2. **Multi-Chain Support**
- Polygon, Arbitrum, Optimism
- Cross-chain position tracking
- Unified APR calculations

### 3. **Machine Learning Integration**
- Predictive APR modeling
- Risk assessment algorithms
- Automated position optimization

### 4. **DeFi Protocol Integration**
- Curve, Balancer, SushiSwap
- Cross-protocol APR comparison
- Portfolio optimization

## 📚 Resources

### Documentation
- [Uniswap V3 Documentation](https://docs.uniswap.org/)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/)
- [Hardhat Documentation](https://hardhat.org/docs/)

### Related Projects
- [The Graph Protocol](https://thegraph.com/) - Alternative indexing solution
- [Chainlink Price Feeds](https://chain.link/) - Price oracle integration
- [Ethereum Events](https://ethereum.org/en/developers/docs/events/) - Event system documentation

## 🤝 Contributing

### Development Setup
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

### Code Standards
- Follow Solidity style guide
- Add comprehensive documentation
- Include unit tests for all functions
- Ensure gas optimization

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

### Issues
- Report bugs via GitHub Issues
- Include detailed reproduction steps
- Provide network and contract addresses

### Questions
- Check existing issues and discussions
- Create new issue for questions
- Tag with appropriate labels

---

**Built with ❤️ for the DeFi community**

*This implementation demonstrates how to build reactive, event-driven DeFi applications using Solidity smart contracts. Use it as a foundation for your own DeFi projects!*

