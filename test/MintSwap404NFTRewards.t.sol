// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/rewards/MintSwap404NFTRewards.sol";
import "../src/erc404/MintSwap404NFT.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract TestMintSwap404NFTRewards is Test {

    address constant SENDER_ADDRESS = 0x54a54832f6B69D6720E3F8FEC582dCcF219006E4;
    address constant SOME_ADDRESS = 0x21cB920Bf98041CD33A68F7543114a98e420Da0B;
    address constant OWNER_ADDRESS = 0x7a12026F109fA19eB58CFDEA01965412d9B5D829;

    address private proxy;
    address private rewardsProxy;

    MintSwap404NFT private instance;

    MintSwap404NFTRewards private rewardsInstance;

    function setUp() public {
        console.log("=======setUp============");
        proxy = Upgrades.deployUUPSProxy(
            "MintSwap404NFT.sol",
            abi.encodeCall(MintSwap404NFT.initialize, (OWNER_ADDRESS,"MintSwap404NFT", "MST", 18, 10000))
        );

        console.log("uups proxy -> %s", proxy);
        
        instance = MintSwap404NFT(proxy);
        assertEq(instance.owner(), OWNER_ADDRESS);

        address implAddressV1 = Upgrades.getImplementationAddress(proxy);

        console.log("impl proxy -> %s", implAddressV1);


        rewardsProxy = Upgrades.deployUUPSProxy(
            "MintSwap404NFTRewards.sol",
            abi.encodeCall(MintSwap404NFTRewards.initialize, (OWNER_ADDRESS,proxy))
        );

        console.log("uups proxy -> %s", rewardsProxy);
        
        rewardsInstance = MintSwap404NFTRewards(rewardsProxy);
        assertEq(rewardsInstance.owner(), OWNER_ADDRESS);

        address implAddressV2 = Upgrades.getImplementationAddress(rewardsProxy);

        console.log("impl proxy -> %s", implAddressV2);
    }

    function testRewards() public {
        // withdraw
        vm.startPrank(OWNER_ADDRESS);
        rewardsInstance.setRewardsAccount(0x9AabD861DFA0dcEf61b55864A03eF257F1c6093A);
        vm.warp(1719468517);
        uint32 _start = 1619457722;
        uint32 _end = 1821457722;
        instance.setMintConfig(_start,_end);
        instance.setERC721TransferExempt(0x9AabD861DFA0dcEf61b55864A03eF257F1c6093A,true);
        instance.mintRewards(0x9AabD861DFA0dcEf61b55864A03eF257F1c6093A,7000);
        assertEq(instance.erc721BalanceOf(0x9AabD861DFA0dcEf61b55864A03eF257F1c6093A), 0);
        assertEq(instance.erc20BalanceOf(0x9AabD861DFA0dcEf61b55864A03eF257F1c6093A), 7000 * 10000 * 10 ** 18);
        vm.stopPrank();

        vm.startPrank(0x9AabD861DFA0dcEf61b55864A03eF257F1c6093A);
        instance.erc20Approve(rewardsProxy, 1000 * 10000 * 10 ** 18);
        vm.stopPrank();
    }
}