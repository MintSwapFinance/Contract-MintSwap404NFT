// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./MintSwap404NFT.sol";

contract MintSwap404NFTStake is Ownable {

    string private constant __NAME = "MintSwap404NFTStake";

    mapping(address => uint256[]) public stakedAddressInfo;

    mapping(address => uint256) public userStakeBenefits;

    MintSwap404NFT public mintSwap404NFT;

    address public caller;

    event TokensStake(address indexed owner, uint256[] tokenIds);

    event TokensWithdraw(address indexed owner, uint256[] tokenIds);

    event UpdatedStakeBenefits(address indexed user, uint256 benefit);

    event WithdrawStakeBenefits(address indexed user, uint256 benefit);

    constructor(address nftContract) Ownable(_msgSender()) {
        mintSwap404NFT  = MintSwap404NFT(nftContract);
        Ownable(msg.sender);
    }

    function name() public view virtual returns (string memory) {
        return __NAME;
    }

    function stake(uint256[] calldata tokenIds) external {
        require(tokenIds.length > 0, "Staking zero tokens");
        address sender = msg.sender;

        for (uint256 i = 0; i < tokenIds.length; ) {
            require(mintSwap404NFT.ownerOf(tokenIds[i]) == sender,"Invalid sender");  // IERC404
            mintSwap404NFT.transferFrom(sender, address(this), tokenIds[i]);
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
            require(mintSwap404NFT.ownerOf(tokenIds[i]) == address(this),"Invalid sender");  // IERC404
            mintSwap404NFT.transferFrom(address(this), sender, tokenIds[i]);
            // stakedAddressInfo pop 找开源
            unchecked {
                ++i;
            }
        }
        emit TokensWithdraw(sender, tokenIds);
    }

    // struct[] for循环
    function updatedStakeBenefits(address user, uint256 benefit) external {
        require(msg.sender == caller, "Invalid sender");
        userStakeBenefits[user] = userStakeBenefits[user] + benefit;
        emit UpdatedStakeBenefits(user, benefit);
    }

    // send eth 可重入
    function withdrawStakeBenefits(uint256 benefit) external {
        // require benefit > 0.00001 Gwei
        address payable sender = payable(msg.sender);
        uint256 userStakeBenefit = userStakeBenefits[sender];
        require(benefit <= userStakeBenefit, "Current user have no benefit");
        userStakeBenefits[sender] = userStakeBenefit - benefit;
        sender.transfer(benefit);  // TransferHelper
        emit WithdrawStakeBenefits(sender, benefit);
    }

    function queryStakeUserBenefits(address user) public view returns (uint256 benefit) {
        return userStakeBenefits[user];
    }

    function setCaller(address _caller) public onlyOwner {
        caller =  _caller;
    }
}