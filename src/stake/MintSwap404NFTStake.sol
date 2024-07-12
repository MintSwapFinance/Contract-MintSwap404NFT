// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "../erc404/MintSwap404NFT.sol";

contract MintSwap404NFTStake is ReentrancyGuardUpgradeable, OwnableUpgradeable, UUPSUpgradeable {

    mapping(uint256 => address) public stakedTokens;

    mapping(address => uint256) public alreadyClaim;

    address public mintswap404NFT;

    address public signer;

    bytes32 internal _INITIAL_DOMAIN_SEPARATOR;

    event TokensStake(address indexed owner, uint256[] tokenIds);

    event TokensWithdraw(address indexed owner, uint256[] tokenIds);

    event WithdrawStakeBenefits(address indexed user, uint256 benefit);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner, address _mintswap404NFT) initializer external {
        require(initialOwner != address(0), "The input parameters of the address type must not be zero address.");
        require(_mintswap404NFT != address(0), "The input parameters of the address type must not be zero address.");
        __Ownable_init(initialOwner);
        __ReentrancyGuard_init();
        __UUPSUpgradeable_init();
        mintswap404NFT = _mintswap404NFT;
        _INITIAL_DOMAIN_SEPARATOR = _computeDomainSeparator();
    }

    function stake(uint256[] calldata tokenIds) external {
        require(tokenIds.length > 0, "Staking zero tokens");
        address sender = msg.sender;

        for (uint256 i = 0; i < tokenIds.length; ) {
            require(IERC404(mintswap404NFT).ownerOf(tokenIds[i]) == sender, "Invalid tokenId");
            stakedTokens[tokenIds[i]] = sender;
            IERC404(mintswap404NFT).transferFrom(sender, address(this), tokenIds[i]);
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
            delete stakedTokens[tokenIds[i]];
            IERC404(mintswap404NFT).transferFrom(address(this), sender, tokenIds[i]);
            unchecked {
                ++i;
            }
        }

        emit TokensWithdraw(sender, tokenIds);
    }

    function withdrawStakeBenefits(
        uint256 _amount,
        bytes32 _r,
        bytes32 _s,
        uint8 _v
    ) external nonReentrant {
        address payable sender = payable(msg.sender);
        require(_verfySigner(sender, _amount, _r, _s, _v) == signer, "Invalid signer");
        require(_amount > alreadyClaim[sender], "Invalid withdraw amount");
        
        uint256 canClaimAmount = _amount - alreadyClaim[sender];
        alreadyClaim[sender] = _amount;
        (bool success, ) = sender.call{value: canClaimAmount}(new bytes(0));
        require(success, 'ETH transfer failed');

        emit WithdrawStakeBenefits(sender, canClaimAmount);
    }

    function setSigner(address _signer) external onlyOwner {
        require(_signer != address(0), "The input parameters of the address type must not be zero address.");
        signer = _signer;
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}

    function _verfySigner(
        address _user,
        uint256 _amount,
        bytes32 _r,
        bytes32 _s,
        uint8 _v
    ) internal view returns (address _signer) {
        _signer = ECDSA.recover(
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    _INITIAL_DOMAIN_SEPARATOR,
                    keccak256(
                        abi.encode(
                            keccak256(
                                "UserStakeBenefit(address user,uint256 amount)"
                            ),
                            _user,
                            _amount
                        )
                    )
                )
            ),
            _v,
            _r,
            _s
        );
    }

    function _computeDomainSeparator() internal view returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256(
                        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                    ),
                    keccak256(bytes("MintSwap404NFTStake")),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }

    receive() external payable {}

}