// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../erc404/MintSwap404NFT.sol";

contract MintSwap404NFTStake is Ownable, ReentrancyGuard {

    mapping(uint256 => address) public stakedToken;

    mapping(address => uint256) public userStakeBenefits;

    address public mintswap404NFT;

    address public benefitUploader;

    uint256 private constant MIN_WITHDRAW_AMOUNT = 0.0000003 ether;

    struct UserBenefit {
        address account;
        uint256 benefit;
    }

    event TokensStake(address indexed owner, uint256[] tokenIds);

    event TokensWithdraw(address indexed owner, uint256[] tokenIds);

    event UpdateStakeBenefits(address indexed user, uint256 benefit);

    event WithdrawStakeBenefits(address indexed user, uint256 benefit);

    constructor(address _mintswap404NFT) Ownable(_msgSender()) {
        mintswap404NFT  = _mintswap404NFT;
    }

    function stake(uint256[] calldata tokenIds) external {
        require(tokenIds.length > 0, "Staking zero tokens");
        address sender = msg.sender;

        for (uint256 i = 0; i < tokenIds.length; ) {
            require(IERC404(mintswap404NFT).ownerOf(tokenIds[i]) == sender, "Invalid tokenId");
            IERC404(mintswap404NFT).transferFrom(sender, address(this), tokenIds[i]);
            stakedToken[tokenIds[i]] = sender;
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
            address nftOwner = stakedToken[tokenIds[i]];
            require(sender == nftOwner, "Invalid sender");
            IERC404(mintswap404NFT).transferFrom(address(this), sender, tokenIds[i]);
            delete stakedToken[tokenIds[i]];
            unchecked {
                ++i;
            }
        }

        emit TokensWithdraw(sender, tokenIds);
    }

    function updatedStakeBenefits(UserBenefit[] calldata userBenefits) external {
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
        require(benefit >= MIN_WITHDRAW_AMOUNT, "The withdrawal amount must be greater than 0.001 ether");
        
        address payable sender = payable(msg.sender);
        uint256 userStakeBenefit = userStakeBenefits[sender];
        require(benefit <= userStakeBenefit, "Invalid withdrawal amount");
        userStakeBenefits[sender] = userStakeBenefit - benefit;

        (bool success, ) = sender.call{value: benefit}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
        emit WithdrawStakeBenefits(sender, benefit);
    }

    function setBenefitUploader(address _benefitUploader) public onlyOwner {
        benefitUploader =  _benefitUploader;
    }
}