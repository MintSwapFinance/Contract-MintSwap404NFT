//SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "forge-std/console.sol";
import "forge-std/Script.sol";
import "../src/erc404/MintSwap404NFT.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract MintSwap404NFTUUPS is Script {

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address owner = vm.envAddress("OWNER");

        address uupsProxy = Upgrades.deployUUPSProxy(
            "MintSwap404NFT.sol",
            abi.encodeCall(MintSwap404NFT.initialize, (owner,"MintSwap404NFT", "MST", 18, 10000))
        );

        console.log("uupsProxy deploy at %s", uupsProxy);

        // contract upgrade
        // Upgrades.upgradeProxy(
        //     0x57aA394Cd408c1dB3E0De979e649e82BF8dD395F,
        //     "MintSwap404NFT.sol",
        //     ""
        // );

        vm.stopBroadcast();
    }
    
}