// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./MintSwap404NFT.sol";

contract MintSwap404NFTBenefit {

    string private constant __NAME = "MintSwap404NFTBenefit";

    mapping(address => uint256) public userStakeBenefits;

    mapping(address => uint256) public userLPBenefits;

    mapping(address => uint256) public userTradeBenefits;

    MintSwap404NFT public mintSwap404NFT;

    address constant MST_OWNER = 0x4565646;

    constructor(address nftContract) {
        mintSwap404NFT  = MintSwap404NFT(nftContract);
    }

    function name() public view virtual returns (string memory) {
        return __NAME;
    }


    function updatedUserStakeBenefits(address user, uint256 benefit) external {
        uint256 userStakeBenefit = userStakeBenefits[user];
        if (userStakeBenefit == 0) {
            userStakeBenefits[user] = benefit;
        } else {
            userStakeBenefits[user] = userStakeBenefit + benefit;
        }
    }

    function updatedUserLPBenefits(address user, uint256 benefit) external {
        uint256 userLPBenefit = userLPBenefits[user];
        if (userLPBenefit == 0) {
            userLPBenefits[user] = benefit;
        } else {
            userLPBenefits[user] = userLPBenefit + benefit;
        }
    }

    function updatedUserTradeBenefits(address user, uint256 benefit) external {
        uint256 userTradeBenefit = userTradeBenefits[user];
        if (userTradeBenefit == 0) {
            userTradeBenefits[user] = benefit;
        } else {
            userTradeBenefits[user] = userTradeBenefit + benefit;
        }
    }


    function withdrawStakeBenefits(uint256 benefit) external {
        mintSwap404NFT.transferFrom(MST_OWNER, msg.sender, benefit);
    }

    function withdrawLPBenefits(uint256 benefit) external {
        mintSwap404NFT.transferFrom(MST_OWNER, msg.sender, benefit);
    }

    function withdrawTradeBenefits(uint256 benefit) external {
        // eth
    }

    function queryUserStakeBenefits(address user) public view returns (uint256 benefit) {
        return userStakeBenefits[user];
    }

    function queryUserLPBenefits(address user) public view returns (uint256 benefit) {
        return userLPBenefits[user];
    }

    function queryUserTradeBenefits(address user) public view returns (uint256 benefit) {
        return userTradeBenefits[user];
    }
}