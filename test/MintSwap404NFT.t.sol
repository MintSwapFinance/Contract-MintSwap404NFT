// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/erc404/MintSwap404NFT.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract TestMintSwap404NFT is Test {
    
    address constant SENDER_ADDRESS = 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D;
    address constant SOME_ADDRESS = 0x21cB920Bf98041CD33A68F7543114a98e420Da0B;
    address constant OWNER_ADDRESS = 0x060368C9765153CD6Adb5a200731591DEceFf114;


    address private proxy;
    MintSwap404NFT private instance;

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
    }

    // function testMint () public {
    //     // =========================publicSale=============================
    //     console.log("testMint");
    //     vm.prank(OWNER_ADDRESS);
    //     vm.warp(1719468517);
    //     uint32 _start = 1619457722;
    //     uint32 _end = 1821457722;
    //     instance.setMintConfig(_start,_end);


    //     vm.startPrank(0xEe73e1787Fb72E480566DB04db04F1955e723b82);
    //     vm.deal(0xEe73e1787Fb72E480566DB04db04F1955e723b82, 10 ether);

    //     instance.publicSale{value: 0.04 ether}(1);

    //     assertEq(instance.erc721BalanceOf(SENDER_ADDRESS), 100);
    //     vm.stopPrank();


    //     vm.startPrank(SENDER_ADDRESS);
    //     vm.deal(SENDER_ADDRESS, 10 ether);

    //     instance.publicSale{value: 4 ether}(100);
    //     assertEq(instance.erc721BalanceOf(SENDER_ADDRESS), 100);
    //     assertEq(instance.erc20BalanceOf(SENDER_ADDRESS), 100 * 10000 * 10 ** 18);
    //     assertEq(address(SENDER_ADDRESS).balance, 6 ether);
    //     assertEq(address(proxy).balance, 4 ether);
    //     vm.stopPrank();


    //     vm.startPrank(OWNER_ADDRESS);
    //     instance.withdrawETH(0x935680FFCa9615a30eBfCA058b15E3Fe4F77D6A7, 1 ether);
    //     assertEq(address(0x935680FFCa9615a30eBfCA058b15E3Fe4F77D6A7).balance, 1 ether);
    //     assertEq(address(proxy).balance, 3 ether);
    //     vm.stopPrank();


    //     vm.startPrank(0x8dafBB4b6975bb7E8dde47635BF4169A80F3C61B);
    //     vm.deal(0x8dafBB4b6975bb7E8dde47635BF4169A80F3C61B, 0.2 ether);

    //     vm.expectRevert(bytes("Not Enough ETH value to mint tokens"));
    //     instance.publicSale{value: 0.2 ether}(6);
    //     // assertEq(instance.erc721BalanceOf(0x8dafBB4b6975bb7E8dde47635BF4169A80F3C61B), 5);
    //     assertEq(address(0x8dafBB4b6975bb7E8dde47635BF4169A80F3C61B).balance, 0.2 ether);
    //     vm.stopPrank();


    //     vm.startPrank(0xEe73e1787Fb72E480566DB04db04F1955e723b82);
    //     vm.deal(0xEe73e1787Fb72E480566DB04db04F1955e723b82, 120 ether);

    //     instance.publicSale{value: 116 ether}(2900);
    //     assertEq(instance.erc721BalanceOf(0xEe73e1787Fb72E480566DB04db04F1955e723b82), 2900);
    //     assertEq(address(0xEe73e1787Fb72E480566DB04db04F1955e723b82).balance, 4 ether);
    //     assertEq(address(proxy).balance, 119 ether);
    //     vm.stopPrank();

    //     vm.startPrank(0x96e25095403E2687754d5F8C9ca97b874A99F739);
    //     vm.deal(0x96e25095403E2687754d5F8C9ca97b874A99F739, 10 ether);

    //     vm.expectRevert(bytes("Mint numberOfTokens exceeds limit"));
    //     instance.publicSale{value: 0.04 ether}(1);
    //     assertEq(instance.erc721BalanceOf(0x96e25095403E2687754d5F8C9ca97b874A99F739), 0);
    //     assertEq(address(0x96e25095403E2687754d5F8C9ca97b874A99F739).balance, 10 ether);
    //     assertEq(address(proxy).balance, 119 ether);
    //     vm.stopPrank();

    //     vm.startPrank(OWNER_ADDRESS);
    //     vm.deal(0x7a12026F109fA19eB58CFDEA01965412d9B5D829, 10 ether);
    //     instance.setERC721TransferExempt(0x7a12026F109fA19eB58CFDEA01965412d9B5D829, true);
    //     instance.mintRewards(0x7a12026F109fA19eB58CFDEA01965412d9B5D829,5000);
    //     assertEq(instance.erc721BalanceOf(0x7a12026F109fA19eB58CFDEA01965412d9B5D829), 0);
    //     assertEq(instance.erc20BalanceOf(0x7a12026F109fA19eB58CFDEA01965412d9B5D829), 5000 * 10000 * 10 ** 18);
    //     assertEq(address(0x7a12026F109fA19eB58CFDEA01965412d9B5D829).balance, 10 ether);
    //     vm.stopPrank();
    // }

}