// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./MintSwap404NFT.sol";

contract MintSwap404NFTBenefit is Ownable {

    string private constant __NAME = "MintSwap404NFTBenefit";

    mapping(address => uint256) public userLPBenefits;

    MintSwap404NFT public mintSwap404NFT;

    address public caller;

    address public whale;

    event UpdatedLPBenefits(address indexed user, uint256 benefit);

    event WithdrawLPBenefits(address indexed user, uint256 benefit);

    constructor(address nftContract) Ownable(_msgSender()) {
        mintSwap404NFT  = MintSwap404NFT(nftContract);
    }

    function name() public view virtual returns (string memory) {
        return __NAME;
    }

    // struct[] for循环
    function updatedUserBenefits(address user, uint256 benefit) external {
        require(msg.sender == caller, "Invalid sender");
        userLPBenefits[user] =  userLPBenefits[user] + benefit;
        emit UpdatedLPBenefits(user, benefit);
    }

    // 可重入
    function withdrawBenefits(uint256 benefit) external {
        // require benefit > 10000
        address sender = msg.sender;
        uint256 userLPBenefit = userLPBenefits[sender];
        require(userLPBenefit >= benefit, "");
        userLPBenefits[sender] = userLPBenefit - benefit;
        mintSwap404NFT.transferFrom(whale, sender, benefit);  // IERC404
        emit WithdrawLPBenefits(sender, benefit);
    }

    function queryUserBenefits(address user) public view returns (uint256 benefit) {
        return userLPBenefits[user];
    }

    function setCaller(address _caller) public onlyOwner {
        caller =  _caller;
    }
}