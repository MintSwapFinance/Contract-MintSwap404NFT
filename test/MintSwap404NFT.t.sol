// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/erc404/MintSwap404NFT.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract TestMintSwap404NFT is Test {
    
    address constant CHEATCODE_ADDRESS = 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D;
    address constant SOME_ADDRESS = 0x21cB920Bf98041CD33A68F7543114a98e420Da0B;

    address private proxy;
    MintSwap404NFT private instance;

    function testMint () public {
        vm.prank(CHEATCODE_ADDRESS);
        instance.publicSale(5);
        assertEq(instance.erc721BalanceOf(CHEATCODE_ADDRESS), 5);
    }

}