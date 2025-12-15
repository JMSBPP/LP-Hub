// // SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;



library EthereumMainnet{
    address constant CREATE2_DEPLOYER = address(0x4e59b44847b379578588920cA78FbF26c0B4956C);

    address constant POOL_MANAGER = address(0x000000000004444c5dc75cB358380D2e3dE08A90);
    address constant STATE_VIEW = address(0x7fFE42C4a5DEeA5b0feC41C94C136Cf115597227);
    address constant POSITION_MANAGER = address(0xbD216513d74C8cf14cf4747E6AaA6420FF64ee9e);
    address constant UNIVERSAL_ROUTER = address(0x66a9893cC07D91D95644AEDD05D03f95e1dBA8Af);
    bytes32 constant ETH_USDC_0_3 = bytes32(0xdce6394339af00981949f5f3baf27e3610c76326a700af57e4b3e3ae4977f78d);
    
    address constant USDC = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    address constant WETH = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address constant ETH = address(0x00);
}