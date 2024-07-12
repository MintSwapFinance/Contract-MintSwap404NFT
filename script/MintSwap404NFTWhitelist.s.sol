//SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "forge-std/Script.sol";
import "../src/erc404/MintSwap404NFT.sol";

contract MintSwap404NFTWhitelistScript is Script {

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address mintswap404NFT = vm.envAddress("MINTSWAP404NFT");

        address[] memory whitelist = vm.envAddress("WHITELIST", ",");

        MintSwap404NFT(mintswap404NFT).addWhitelist(whitelist);

        vm.stopBroadcast();
    }
    
}