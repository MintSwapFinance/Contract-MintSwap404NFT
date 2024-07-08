//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "./ERC404.sol";
import "../metadata/IMetadataRenderer.sol";

contract MintSwap404NFT is ERC404, OwnableUpgradeable, UUPSUpgradeable {

    uint256 public constant PUBLIC_SALE_PRICE = 0.04 ether;

    uint256 public constant WHITELIST_SALE_PRICE = 0.028 ether;

    uint256 public constant SALE_TOTAL_COUNT = 3000;

    uint256 public constant WL_SALE_COUNT = 500;

    mapping(address => bool) public whitelist;

    uint256 public _publicMintedCount;
    uint256 public _wlMintedCount;

    struct MintConfig {
        uint32 startTime;
        uint32 endTime;
    }

    MintConfig public mintConfig;

    MintConfig public wlConfig;

    mapping(address => bool) public wlMinted;

    uint256 public constant MINTSWAP_REWARDS_COUNT = 7000;

    uint256 public _mintswapMintedCount;

    address public metadataRenderer;

    error MintNotStart();
    error MintFinished();

    event WithdrawETH(address indexed to, uint256 amount);

    error UnauthorizedMinter(address minter);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }
    
    function initialize(
        address initialOwner, 
        string memory name_, 
        string memory symbol_, 
        uint8 decimals_, 
        uint256 unitMultiplicator_
    ) public initializer {
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
        __ERC404_init(name_, symbol_, decimals_, unitMultiplicator_);
    }

    modifier isPublicSaleTime() {
        if (block.timestamp < mintConfig.startTime) revert MintNotStart();
        if (block.timestamp > mintConfig.endTime) revert MintFinished();
        _;
    }

    modifier isWLSaleTime() {
        if (block.timestamp < wlConfig.startTime) revert MintNotStart();
        if (block.timestamp > wlConfig.endTime) revert MintFinished();
        _;
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        require(ownerOf(tokenId) != address(0), "Invalid tokenId");
        return IMetadataRenderer(metadataRenderer).tokenURI(tokenId);
    }

    function setMetadataRenderer(address _metadataRenderer) external onlyOwner {
        metadataRenderer = _metadataRenderer;
    }

    function setERC721TransferExempt(address exemptAddress, bool state) external onlyOwner {
        _setERC721TransferExempt(exemptAddress, state);
    }

    function wlSale() external payable isWLSaleTime {
        address account = _msgSender();
        if (!whitelist[account]) revert UnauthorizedMinter(account);

        require(!wlMinted[account], "This account has already WL minted");
        require(_wlMintedCount + 1 <= WL_SALE_COUNT, "WL mint exceeds limit");
        require(WHITELIST_SALE_PRICE <= msg.value, "Not Enough ETH value to WL mint tokens");

        _mintERC20(account, units);
        wlMinted[account] = true;
        _publicMintedCount++;
        _wlMintedCount++;
    }

    function publicSale(uint numberOfTokens) external payable isPublicSaleTime {
        require(numberOfTokens > 0 && _publicMintedCount + numberOfTokens <= SALE_TOTAL_COUNT, "Mint numberOfTokens exceeds limit");
        require(PUBLIC_SALE_PRICE * numberOfTokens <= msg.value, "Not Enough ETH value to mint tokens");
        
        _mintERC20(_msgSender(), numberOfTokens * units);
        _publicMintedCount += numberOfTokens;
    }

    function mintRewards(address exemptAddress, uint256 amount) external onlyOwner {
        require(erc721TransferExempt(exemptAddress), "The address is not erc721TransferExempt");
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

    function setWLConfig(
        uint32 _startTime,
        uint32 _endTime
    ) external onlyOwner {
        require(_endTime > _startTime, "MUST(_endTime > _startTime)");
        wlConfig = MintConfig( _startTime, _endTime);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}

    function withdrawETH(address _to, uint256 _amount) external onlyOwner {
        (bool success, ) = _to.call{value: _amount}(new bytes(0));
        require(success, 'ETH transfer failed');
        emit WithdrawETH(_to, _amount);
    }

    function addWhitelist(address[] calldata _addresses) external onlyOwner {
        for (uint i = 0; i < _addresses.length; i++) {
            whitelist[_addresses[i]] = true;
        }
    }

}
