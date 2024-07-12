//SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "forge-std/console.sol";
import "forge-std/Script.sol";
import "../src/stake/MintSwap404NFTStake.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract MintSwap404NFTStakeUUPS is Script {

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address owner = vm.envAddress("OWNER");
        address mintswap404NFT = vm.envAddress("MINTSWAP404NFT");

        address uupsProxy = Upgrades.deployUUPSProxy(
            "MintSwap404NFTStake.sol",
            abi.encodeCall(MintSwap404NFTStake.initialize, (owner, mintswap404NFT))
        );

        console.log("uupsProxy deploy at %s", uupsProxy);

        // contract upgrade
        // Upgrades.upgradeProxy(
        //     0x66C377A3464B08A0B14d502078b95E9bC31eb016,
        //     "MintSwap404NFTStake.sol",
        //     ""
        // );

        vm.stopBroadcast();
    }
    
}