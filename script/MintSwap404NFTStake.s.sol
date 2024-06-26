pragma solidity ^0.8.20;

import "forge-std/console.sol";
import "forge-std/Script.sol";
import "../src/stake/MintSwap404NFTStake.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract MintSwap404NFTStakeUUPS is Script {

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address owner = vm.envAddress("OWNER");

        address uupsProxy = Upgrades.deployUUPSProxy(
            "MintSwap404NFTStake.sol",
            abi.encodeCall(MintSwap404NFTStake.initialize, (owner))
        );

        console.log("uupsProxy deploy at %s", uupsProxy);

        vm.stopBroadcast();
    }
}