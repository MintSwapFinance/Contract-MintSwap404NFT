// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./MintSwap404NFT.sol";

contract MintSwap404NFTStake {

    string private constant __NAME = "MintSwap404NFTStake";

    mapping(address => uint256[]) public stakedAddressInfo;

    mapping(address => uint256) public userStakeBenefits;

    MintSwap404NFT public mintSwap404NFT;

    event TokensStake(address indexed owner, uint256[] tokenIds);

    event TokensWithdraw(address indexed owner, uint256[] tokenIds);

    event UpdatedStakeBenefits(address indexed user, uint256 benefit);

    event WithdrawStakeBenefits(address indexed user, uint256 benefit);

    constructor(address nftContract) {
        mintSwap404NFT  = MintSwap404NFT(nftContract);
    }

    function name() public view virtual returns (string memory) {
        return __NAME;
    }

    function stake(uint256[] calldata tokenIds) external {
        require(tokenIds.length > 0, "MP: Staking zero tokens");
        address sender = msg.sender;

        for (uint256 i = 0; i < tokenIds.length; ) {
            require(mintSwap404NFT.ownerOf(tokenIds[i]) == sender,"Invalid sender");
            mintSwap404NFT.transferFrom(sender, address(this), tokenIds[i]);
            // stakedAddressInfo[sender].push(tokenIds[i]);
            unchecked {
                ++i;
            }
        }
        emit TokensStake(sender, tokenIds);
    }

    function withdraw(uint256[] calldata tokenIds) external {
        require(tokenIds.length > 0, "Withdraw zero tokens");
        address sender = msg.sender;

        for (uint256 i = 0; i < tokenIds.length; ) {
            require(mintSwap404NFT.ownerOf(tokenIds[i]) == address(this),"Invalid sender");
            mintSwap404NFT.transferFrom(address(this), sender, tokenIds[i]);
            unchecked {
                ++i;
            }
        }
        emit TokensWithdraw(sender, tokenIds);
    }

    function updatedStakeBenefits(address user, uint256 benefit) external {
        uint256 userStakeBenefit = userStakeBenefits[user];
        if (userStakeBenefit == 0) {
            userStakeBenefits[user] = benefit;
        } else {
            userStakeBenefits[user] = userStakeBenefit + benefit;
        }
        emit UpdatedStakeBenefits(user, benefit);
    }

    // send eth
    function withdrawStakeBenefits(uint256 benefit) external {
        address payable sender = payable(msg.sender);
        uint256 userStakeBenefit = userStakeBenefits[sender];
        require(userStakeBenefit > 0 && benefit <= userStakeBenefit, "Current user have no benefit");
        sender.transfer(benefit);
        userStakeBenefits[sender] = 0;
        emit WithdrawStakeBenefits(sender, benefit);
    }

    function queryStakeUserBenefits(address user) public view returns (uint256 benefit) {
        return userStakeBenefits[user];
    }
}