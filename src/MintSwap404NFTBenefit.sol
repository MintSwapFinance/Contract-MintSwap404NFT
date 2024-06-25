// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./MintSwap404NFT.sol";

contract MintSwap404NFTBenefit is Ownable, ReentrancyGuard {

    string private constant __NAME = "MintSwap404NFTBenefit";

    struct UserBenefit {
        address account;
        uint256 benefit;
    }

    mapping(address => uint256) public userRewardsBenefits;

    address public mintswap404NFT;

    address public benefitUploader;

    address public rewardsAccount;

    uint256 private constant MIN_WITHDRAW_AMOUNT = 1000;

    event UpdateRewardsBenefits(address indexed user, uint256 benefit);

    event WithdrawRewardsBenefits(address indexed user, uint256 benefit);

    constructor(address _mintswap404NFT) Ownable(_msgSender()) {
        mintswap404NFT  = _mintswap404NFT;
    }

    function name() public view virtual returns (string memory) {
        return __NAME;
    }

    function updatedUserBenefits(UserBenefit[] calldata userBenefits) external {
        require(msg.sender == benefitUploader, "Invalid benefitUploader");
        require(userBenefits.length > 0, "Empty Benefits");

        for (uint256 i = 0; i < userBenefits.length; ) {
            UserBenefit calldata _userBenefit = userBenefits[i];
            address _account  = _userBenefit.account;
            uint256 _benefit  = _userBenefit.benefit;

            userRewardsBenefits[_account] += _benefit;
            emit UpdateRewardsBenefits(_account, _benefit);
            unchecked {
                ++i;
            }
        }
    }

    function withdrawBenefits(uint256 benefit) external nonReentrant {
        require(benefit >= MIN_WITHDRAW_AMOUNT, "The withdrawal amount must be greater than 1000");
        
        address sender = msg.sender;
        uint256 userRewardsBenefit = userRewardsBenefits[sender];
        require(benefit <= userRewardsBenefit, "Invalid withdrawal amount");
        userRewardsBenefits[sender] = userRewardsBenefit - benefit;

        IERC404(mintswap404NFT).transferFrom(rewardsAccount, sender, benefit);
        emit WithdrawRewardsBenefits(sender, benefit);
    }

    function setBenefitUploader(address _benefitUploader) public onlyOwner {
        benefitUploader = _benefitUploader;
    }

    function setRewardsAccount(address _rewardsAccount) public onlyOwner {
        rewardsAccount = _rewardsAccount;
    }
    
}