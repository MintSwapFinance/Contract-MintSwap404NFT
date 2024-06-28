// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "../erc404/MintSwap404NFT.sol";

contract MintSwap404NFTStake is ReentrancyGuardUpgradeable, OwnableUpgradeable, UUPSUpgradeable {

    mapping(uint256 => address) public stakedTokens;

    mapping(address => uint256) public userStakeBenefits;

    address public mintswap404NFT;

    address public benefitUploader;

    uint256 public constant MIN_WITHDRAW_AMOUNT = 0.0000001 ether;

    struct UserBenefit {
        address account;
        uint256 benefit;
    }

    event TokensStake(address indexed owner, uint256[] tokenIds);

    event TokensWithdraw(address indexed owner, uint256[] tokenIds);

    event UpdateStakeBenefits(address indexed user, uint256 benefit);

    event WithdrawStakeBenefits(address indexed user, uint256 benefit);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner,address _mintswap404NFT) initializer public {
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();
        mintswap404NFT  = _mintswap404NFT;
    }

    function stake(uint256[] calldata tokenIds) external {
        require(tokenIds.length > 0, "Staking zero tokens");
        address sender = msg.sender;

        for (uint256 i = 0; i < tokenIds.length; ) {
            require(IERC404(mintswap404NFT).ownerOf(tokenIds[i]) == sender, "Invalid tokenId");
            IERC404(mintswap404NFT).transferFrom(sender, address(this), tokenIds[i]);
            stakedTokens[tokenIds[i]] = sender;
            unchecked {
                ++i;
            }
        }

        emit TokensStake(sender, tokenIds);
    }

    function withdraw(uint256[] calldata tokenIds) external {
        require(tokenIds.length > 0, "Withdrawing zero tokens");
        address sender = msg.sender;

        for (uint256 i = 0; i < tokenIds.length; ) {
            address nftOwner = stakedTokens[tokenIds[i]];
            require(sender == nftOwner, "Invalid tokenId");
            IERC404(mintswap404NFT).transferFrom(address(this), sender, tokenIds[i]);
            delete stakedTokens[tokenIds[i]];
            unchecked {
                ++i;
            }
        }

        emit TokensWithdraw(sender, tokenIds);
    }

    function updateStakeBenefits(UserBenefit[] calldata userBenefits) external {
        require(msg.sender == benefitUploader, "Invalid benefitUploader");
        require(userBenefits.length > 0, "Empty Benefits");

        for (uint256 i = 0; i < userBenefits.length; ) {
            UserBenefit calldata _userBenefit = userBenefits[i];
            address _account  = _userBenefit.account;
            uint256 _benefit  = _userBenefit.benefit;
            
            userStakeBenefits[_account] += _benefit;
            emit UpdateStakeBenefits(_account, _benefit);
            unchecked {
                ++i;
            }
        }
    }

    function withdrawStakeBenefits(uint256 benefit) external nonReentrant {
        require(benefit >= MIN_WITHDRAW_AMOUNT, "The withdrawal amount must be greater than 0.0000001 ether");
        
        address payable sender = payable(msg.sender);
        uint256 userStakeBenefit = userStakeBenefits[sender];
        require(benefit <= userStakeBenefit, "Invalid withdrawal amount");
        userStakeBenefits[sender] = userStakeBenefit - benefit;

        (bool success, ) = sender.call{value: benefit}(new bytes(0));
        require(success, 'ETH transfer failed');
        emit WithdrawStakeBenefits(sender, benefit);
    }

    function setBenefitUploader(address _benefitUploader) public onlyOwner {
        benefitUploader =  _benefitUploader;
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}

    receive() external payable {
    }
}