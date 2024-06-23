// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "MintSwap404NFT.sol";

contract MintSwap404NFTStake {

    string private constant __NAME = "MintSwap404NFTStake";

    mapping(address => uint256[]) public stakedAddressInfo;

    MintSwap404NFT public mintSwap404NFT;


    event TokensStake(address indexed owner, uint256[] tokenIds);

    event TokensWithdraw(address indexed owner, uint256[] tokenIds);

    constructor(address nftContract) {
        mintSwap404NFT  = MintSwap404NFT(mintSwap404NFT);
    }

    function name() public view virtual returns (string memory) {
        return __NAME;
    }

    function stake(address nftContract, uint256[] calldata tokenIds) external {
        require(tokenIds.length > 0, "MP: Staking zero tokens");
        address sender = _msgSender();

        for (uint256 i = 0; i < tokenIds.length; ) {
            if (mintSwap404NFT.ownerOf(tokenIds[i]) == sender) {
                mintSwap404NFT.transferFrom(sender, address(this), tokenIds[i]);
                // stakedAddressInfo[sender].push(tokenIds[i]);
            }
            unchecked {
                ++i;
            }
        }
        emit TokensStake(owner, tokenIds);
    }


    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function withdraw(address nftContract, uint256[] calldata tokenIds) external {
        require(tokenIds.length > 0, "Withdraw zero tokens");
        address sender = _msgSender();

        for (uint256 i = 0; i < tokenIds.length; ) {
            if (mintSwap404NFT.ownerOf(tokenIds[i]) == sender) {
                mintSwap404NFT.transferFrom(address(this), sender, tokenIds[i]);
                // stakedAddressInfo[sender].push(tokenIds[i]);
            }
            unchecked {
                ++i;
            }
        }
        emit TokensWithdraw(owner, tokenIds);
    }

}