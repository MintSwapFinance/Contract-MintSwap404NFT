pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/erc404/MintSwap404NFT.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract TestMintSwap404NFT is Test {
    address constant CHEATCODE_ADDRESS = 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D;
    address constant SOME_ADDRESS = 0x21cB920Bf98041CD33A68F7543114a98e420Da0B;
    address constant OWNER_ADDRESS = 0x060368C9765153CD6Adb5a200731591DEceFf114;


    address private proxy;
    MintSwap404NFT private instance;

    function setUp() public {
        proxy = Upgrades.deployUUPSProxy(
            "MintSwap404NFT.sol",
            abi.encodeCall(MintSwap404NFT.initialize, (CHEATCODE_ADDRESS))
        );

        console.log("uups proxy -> %s", proxy);
        
        instance = MintSwap404NFT(proxy);
        assertEq(instance.owner(), CHEATCODE_ADDRESS);

        address implAddressV1 = Upgrades.getImplementationAddress(proxy);

        console.log("impl proxy -> %s", implAddressV1);
    }

    function testMint () public {
        console.log("testMint");
        vm.prank(CHEATCODE_ADDRESS);
        uint32 _start = 1719368559;
        uint32 _end = 1719968559;
        instance.setMintConfig(_start,_end);
        instance.publicSale(5);
        assertEq(instance.erc721BalanceOf(CHEATCODE_ADDRESS), 5);
    }
}