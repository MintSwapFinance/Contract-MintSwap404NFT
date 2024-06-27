// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "../erc404/MintSwap404NFT.sol";

contract MintSwap404NFTRewards is Initializable, OwnableUpgradeable, UUPSUpgradeable {

    struct UserBenefit {
        address account;
        uint256 benefit;
    }

    mapping(address => uint256) public userRewardsBenefits;

    address public mintswap404NFT;

    address public benefitUploader;

    address public rewardsAccount;

    uint256 public constant MIN_WITHDRAW_AMOUNT = 1000;

    event UpdateRewardsBenefits(address indexed user, uint256 benefit);

    event WithdrawRewardsBenefits(address indexed user, uint256 benefit);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner, address _mintswap404NFT) initializer public {
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
        mintswap404NFT  = _mintswap404NFT;
    }

    function updatedUserBenefits(UserBenefit[] calldata userBenefits) external {
        require(msg.sender == benefitUploader, "Invalid benefitUploader");
        require(userBenefits.length > 0, "Empty Benefits");

        for (uint256 i = 0; i < userBenefits.length; ) {
            UserBenefit calldata _userBenefit = userBenefits[i];
            address _account = _userBenefit.account;
            uint256 _benefit = _userBenefit.benefit;

            userRewardsBenefits[_account] += _benefit;
            emit UpdateRewardsBenefits(_account, _benefit);
            unchecked {
                ++i;
            }
        }
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