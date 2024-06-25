// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../node_modules/@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./MintSwap404NFT.sol";

contract MintSwap404NFTBenefit is Ownable, ReentrancyGuard {

    string private constant __NAME = "MintSwap404NFTBenefit";

    struct UserBenefit {
        address account;
        uint256 benefit;
    }

    mapping(address => uint256) public userLPBenefits;

    address public mintSwap404NFT;

    address public caller;

    address public manageAccount;

    uint256 private constant MIN_WITHDRAW_AMOUNT = 1000;

    event UpdatedLPBenefits(address indexed user, uint256 benefit);

    event WithdrawLPBenefits(address indexed user, uint256 benefit);

    constructor(address nftContract) Ownable(_msgSender()) {
        mintSwap404NFT  = nftContract;
    }

    function name() public view virtual returns (string memory) {
        return __NAME;
    }

    // struct[] for循环
    function updatedUserBenefits(UserBenefit[] calldata userBenefits) external {
        require(msg.sender == caller, "Invalid sender");
        require(userBenefits.length > 0, "Empty Benefits");
        for (uint256 i = 0; i < userBenefits.length; ) {
            UserBenefit memory _userBenefit = userBenefits[i];
            address _account  = _userBenefit.account;
            uint256 _benefit  = _userBenefit.benefit;
            userLPBenefits[_account] = userLPBenefits[_account] + _benefit;
            emit UpdatedLPBenefits(_account, _benefit);
            unchecked {
                ++i;
            }
        }
    }

    // 可重入
    function withdrawBenefits(uint256 benefit) external nonReentrant {
        // require benefit > 10000
        require(benefit >= MIN_WITHDRAW_AMOUNT, "The withdrawal amount must be greater than 1000");
        address sender = msg.sender;
        uint256 userLPBenefit = userLPBenefits[sender];
        require(userLPBenefit >= benefit, "Invalid benefit");
        userLPBenefits[sender] = userLPBenefit - benefit;
        IERC404(mintSwap404NFT).transferFrom(manageAccount, sender, benefit);  // IERC404
        emit WithdrawLPBenefits(sender, benefit);
    }

    function queryUserBenefits(address user) public view returns (uint256 benefit) {
        return userLPBenefits[user];
    }

    function setCaller(address _caller) public onlyOwner {
        caller =  _caller;
    }

    function setManageAccount(address account) public onlyOwner {
        manageAccount = account;
    }
}