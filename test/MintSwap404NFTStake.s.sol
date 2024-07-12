// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "forge-std/Test.sol";
import "../src/stake/MintSwap404NFTStake.sol";
import "../src/erc404/MintSwap404NFT.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract TestMintSwap404NFTStake is Test {

    address constant SENDER_ADDRESS = 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D;
    address constant SOME_ADDRESS = 0x21cB920Bf98041CD33A68F7543114a98e420Da0B;
    address constant OWNER_ADDRESS = 0x060368C9765153CD6Adb5a200731591DEceFf114;

    address private proxy;
    address payable private stakeProxy;

    MintSwap404NFT private instance;

    MintSwap404NFTStake private stakeInstance;

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


        stakeProxy = payable(Upgrades.deployUUPSProxy(
            "MintSwap404NFTStake.sol",
            abi.encodeCall(MintSwap404NFTStake.initialize, (OWNER_ADDRESS,proxy))
        ));

        console.log("uups proxy -> %s", stakeProxy);
        
        stakeInstance = MintSwap404NFTStake(stakeProxy);
        assertEq(stakeInstance.owner(), OWNER_ADDRESS);

        address implAddressV2 = Upgrades.getImplementationAddress(stakeProxy);

        console.log("impl proxy -> %s", implAddressV2);
    }

    // stake
    function testStake() public {
        vm.startPrank(OWNER_ADDRESS);
        vm.warp(1719468517);
        uint32 _start = 1619457722;
        uint32 _end = 1821457722;
        instance.setMintConfig(_start,_end);
        vm.stopPrank();

        vm.startPrank(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
        vm.deal(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D, 10 ether);
        instance.publicSale{value: 0.04 ether}(1);
        uint256[] memory ownesTokenIds = instance.owned(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
        assertEq(ownesTokenIds.length, 1);
        console.log(ownesTokenIds[0]);

        // approve
        instance.setApprovalForAll(stakeProxy, true);
        assertEq(instance.isApprovedForAll(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D,stakeProxy), true);

        // stake
        stakeInstance.stake(ownesTokenIds);
        assertEq(instance.ownerOf(ownesTokenIds[0]), stakeProxy);
        assertEq(instance.owned(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D).length, 0);



        // withdraw
        stakeInstance.withdraw(ownesTokenIds);
        assertEq(instance.ownerOf(ownesTokenIds[0]), 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
        assertEq(instance.owned(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D).length, 1);
        vm.stopPrank();

    }
}