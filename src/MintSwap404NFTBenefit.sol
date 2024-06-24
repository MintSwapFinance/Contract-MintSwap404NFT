// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./MintSwap404NFT.sol";

contract MintSwap404NFTBenefit is Ownable {

    string private constant __NAME = "MintSwap404NFTBenefit";

    mapping(address => uint256) public userBenefits;

    function name() public view virtual returns (string memory) {
        return __NAME;
    }


    function updatedUserBenefits(address user, uint256 benefit) public onlyOwner {
        uint256 userBenefit = userBenefits[user];
        if (userBenefit == 0) {
            userBenefits[user] = benefit;
        } else {
            userBenefits[user] = userBenefit + benefit;
        }
    }


    function withdrawBenefits(uint256 benefit) external {

    }

    function queryUserBenefits(address user) public view returns (uint256 benefit) {
        return userBenefits[user];
    }
}