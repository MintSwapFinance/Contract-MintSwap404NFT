//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "../lib/ERC404.sol";
import "../lib/IMetadataRenderer.sol";

contract MintSwap404NFT is ERC404, Initializable, OwnableUpgradeable, UUPSUpgradeable {
    using Strings for uint256;
    uint256 _maxTotalSupplyERC721 = 10000;

    uint256 public constant PUBLIC_SALE_PRICE = 0.04 ether;

    uint256 public constant PUBLIC_SALE_COUNT = 3000;

    uint256 public _publicMintedCount = 0;

    struct MintConfig {
        uint32 startTime;
        uint32 endTime;
    }

    MintConfig public mintConfig;

    address public metadataRenderer;

    uint256 public constant MINTSWAP_REWARDS_COUNT = 7000;

    uint256 private _mintswapMintedCount = 0;

    error MintNotStart();
    error MintFinished();

    constructor(
        address initialOwner_
    )
        ERC404("MintSwap404NFT", "MST", 18, 10000)
        // Ownable(initialOwner_)
    {

    }

    function initialize(address initialOwner) initializer public {
        // ERC404("MintSwap404NFT", "MST", 18, 10000);
        // __ERC721_init("MintSwap404NFT", "MST");
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
    }


    modifier isPublicSaleTime() {
        if (block.timestamp < mintConfig.startTime) revert MintNotStart();
        if (block.timestamp > mintConfig.endTime) revert MintFinished();
        _;
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        return IMetadataRenderer(metadataRenderer).tokenURI(tokenId);
    }

    function setMetadataRenderer(address _metadataRenderer) public onlyOwner {
        metadataRenderer = _metadataRenderer;
    }

    function publicSale(uint numberOfTokens) external payable isPublicSaleTime {
        require(numberOfTokens > 0 && _publicMintedCount + numberOfTokens <= PUBLIC_SALE_COUNT, "Mint numberOfTokens exceeds limit");
        require(PUBLIC_SALE_PRICE * numberOfTokens <= msg.value, "Not Enough ETH value to mint tokens");
        
        _mintERC20(_msgSender(), numberOfTokens * units);
        _publicMintedCount += numberOfTokens;
    }

    function setERC721TransferExempt(address exemptAddress) external onlyOwner {
        _setERC721TransferExempt(exemptAddress, true);
    }

    function mintRewards(address exemptAddress, uint256 amount) external onlyOwner {
        require(amount > 0 && _mintswapMintedCount + amount <= MINTSWAP_REWARDS_COUNT, "The maximum mint rewards quantity cannot exceed 7000");
        _mintERC20(exemptAddress, amount * units);
        _mintswapMintedCount += amount;
    }

    function setMintConfig(
        uint32 _startTime,
        uint32 _endTime
    ) external onlyOwner {
        require(_endTime > _startTime, "MUST(_endTime > _startTime)");
        mintConfig = MintConfig( _startTime, _endTime);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}

}
