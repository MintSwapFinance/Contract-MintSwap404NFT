// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "../erc404/MintSwap404NFT.sol";

contract MintSwap404NFTRewards is OwnableUpgradeable, UUPSUpgradeable {

    struct UserBenefit {
        address account;
        uint256 benefit;
    }

    mapping(address => uint256) public userRewardsBenefits;

    mapping(uint256 => bool) public rewardsUploadTags;

    address public mintswap404NFT;

    address public benefitUploader;

    address public rewardsAccount;

    uint256 public constant MIN_WITHDRAW_AMOUNT = 1000;

    event WithdrawRewardsBenefits(address indexed user, uint256 benefit);

    event UserRewardsUploaded(address indexed user, uint256 benefit, uint256 uploadTag);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner, address _mintswap404NFT) initializer public {
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
        mintswap404NFT = _mintswap404NFT;
    }

    function uploadUserBenefits(UserBenefit[] calldata userBenefits, uint256 uploadTag) external {
        require(!rewardsUploadTags[uploadTag], "The rewards for this tag has already been uploaded");
        require(msg.sender == benefitUploader, "Invalid benefitUploader");
        require(userBenefits.length > 0, "Empty Benefits");

        for (uint256 i = 0; i < userBenefits.length; ) {
            UserBenefit calldata _userBenefit = userBenefits[i];
            address _account = _userBenefit.account;
            uint256 _benefit = _userBenefit.benefit;

            userRewardsBenefits[_account] += _benefit;
            emit UserRewardsUploaded(_account, _benefit, uploadTag);
            unchecked {
                ++i;
            }
        }
        rewardsUploadTags[uploadTag] = true;
    }

    function withdrawBenefits(uint256 benefit) external {
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

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}
    
}