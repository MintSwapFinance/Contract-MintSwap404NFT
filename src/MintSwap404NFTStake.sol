// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./MintSwap404NFT.sol";

contract MintSwap404NFTStake is Ownable, ReentrancyGuard {

    string private constant __NAME = "MintSwap404NFTStake";

    mapping(address => uint256[]) public stakedAddressInfo;

    mapping(address => uint256) public userStakeBenefits;

    address public mintswap404NFT;

    address public benefitUploader;

    uint256 private constant MIN_WITHDRAW_AMOUNT = 0.001 ether;

    struct UserBenefit {
        address account;
        uint256 benefit;
    }

    event TokensStake(address indexed owner, uint256[] tokenIds);

    event TokensWithdraw(address indexed owner, uint256[] tokenIds);

    event UpdateStakeBenefits(address indexed user, uint256 benefit);

    event WithdrawStakeBenefits(address indexed user, uint256 benefit);

    event Received(address indexed sender, uint256 value);

    constructor(address _mintswap404NFT) Ownable(_msgSender()) {
        mintswap404NFT  = _mintswap404NFT;
    }

    function name() public view virtual returns (string memory) {
        return __NAME;
    }

    function stake(uint256[] calldata tokenIds) external {
        require(tokenIds.length > 0, "Staking zero tokens");
        address sender = msg.sender;

        for (uint256 i = 0; i < tokenIds.length; ) {
            require(IERC404(mintswap404NFT).ownerOf(tokenIds[i]) == sender, "Invalid tokenId");
            IERC404(mintswap404NFT).transferFrom(sender, address(this), tokenIds[i]);
            stakedAddressInfo[sender].push(tokenIds[i]);
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
            require(IERC404(mintswap404NFT).ownerOf(tokenIds[i]) == address(this), "Invalid tokenId");

            for (uint256 j = 0; j < stakedAddressInfo[sender].length;) {
                if (tokenIds[i] == stakedAddressInfo[sender][j]) {
                    // replace tokenId and pop
                    stakedAddressInfo[sender][j] = stakedAddressInfo[sender][stakedAddressInfo[sender].length - 1];
                    stakedAddressInfo[sender].pop();
                }
                unchecked {
                    ++j;
                }
            }

            IERC404(mintswap404NFT).transferFrom(address(this), sender, tokenIds[i]);
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

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
    
}