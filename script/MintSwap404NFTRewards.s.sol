//SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "forge-std/console.sol";
import "forge-std/Script.sol";
import "../src/rewards/MintSwap404NFTRewards.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract MintSwap404NFTRewardsUUPS is Script {

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address owner = vm.envAddress("OWNER");

        address mintswap404NFT = vm.envAddress("MINTSWAP404NFT");

        address uupsProxy = Upgrades.deployUUPSProxy(
            "MintSwap404NFTRewards.sol",
            abi.encodeCall(MintSwap404NFTRewards.initialize, (owner, mintswap404NFT))
        );

        console.log("uupsProxy deploy at %s", uupsProxy);

        // contract upgrade
        // Upgrades.upgradeProxy(
        //     0xBcdFd6f57dad9A9817f3622709d9Eed0576118E1,
        //     "MintSwap404NFTRewards.sol",
        //     ""
        // );

        vm.stopBroadcast();
    }
    
}