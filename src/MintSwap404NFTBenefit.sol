// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./MintSwap404NFT.sol";

contract MintSwap404NFTBenefit {

    string private constant __NAME = "MintSwap404NFTBenefit";

    mapping(address => uint256) public userLPBenefits;

    MintSwap404NFT public mintSwap404NFT;

    event UpdatedLPBenefits(address indexed user, uint256 benefit);

    event WithdrawLPBenefits(address indexed user, uint256 benefit);

    constructor(address nftContract) {
        mintSwap404NFT  = MintSwap404NFT(nftContract);
    }

    function name() public view virtual returns (string memory) {
        return __NAME;
    }

    function updatedUserBenefits(address user, uint256 benefit) external {
        uint256 userLPBenefit = userLPBenefits[user];
        if (userLPBenefit == 0) {
            userLPBenefits[user] = benefit;
        } else {
            userLPBenefits[user] = userLPBenefit + benefit;
        }
        emit UpdatedLPBenefits(user, benefit);
    }

    function withdrawBenefits(uint256 benefit) external {
        address sender = msg.sender;
        uint256 userLPBenefit = userLPBenefits[sender];
        require(userLPBenefit > 0 && userLPBenefit >= benefit, "");
        mintSwap404NFT.transferFrom(address(this), sender, benefit);
        userLPBenefits[sender] = 0;
        emit WithdrawLPBenefits(sender, benefit);
    }

    function queryUserBenefits(address user) public view returns (uint256 benefit) {
        return userLPBenefits[user];
    }
}