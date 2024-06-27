// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/rewards/MintSwap404NFTRewards.sol";
import "../src/erc404/MintSwap404NFT.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
contract TestMintSwap404NFTRewards is Test {
    address constant SENDER_ADDRESS = 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D;
    address constant SOME_ADDRESS = 0x21cB920Bf98041CD33A68F7543114a98e420Da0B;
    address constant OWNER_ADDRESS = 0x060368C9765153CD6Adb5a200731591DEceFf114;


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
        vm.startPrank(OWNER_ADDRESS);
        rewardsInstance.setBenefitUploader(0xEe73e1787Fb72E480566DB04db04F1955e723b82);
        vm.stopPrank();

        vm.startPrank(0xEe73e1787Fb72E480566DB04db04F1955e723b82);
        MintSwap404NFTRewards.UserBenefit memory userBenefit1 = new MintSwap404NFTRewards.UserBenefit();
        userBenefit1.account = 0xb84C357F5F6BB7f36632623105F10cFAD3DA18A6;
        userBenefit1.benefit = 265;

        MintSwap404NFTRewards.UserBenefit[] memory userBenefits = new MintSwap404NFTRewards.UserBenefit[](1);
        userBenefits[0] = userBenefit1;

        rewardsInstance.updatedUserBenefits(userBenefits);
        vm.stopPrank();


    }
}