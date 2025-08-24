// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;


interface ILPHub{
    function calculateFeesFromVolume(
        bytes memory encodedPoolLpMetrics
    ) external returns(uint256);
}