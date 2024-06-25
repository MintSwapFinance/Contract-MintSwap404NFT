//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "../lib/ERC404.sol";
import "../lib/IMetadataRenderer.sol";

contract MintSwap404NFT is Ownable, ERC404 {
    using Strings for uint256;
    uint256 _maxTotalSupplyERC721 = 10000;

    uint256 public constant PUBLIC_SALE_PRICE = 0.04 ether; //0.04 ETH

    uint256 public constant PUBLIC_SALE_COUNT = 3000; //public sale count

    uint256 public _publicMintedCount = 0;

    struct MintConfig {
        uint32 startTime;
        uint32 endTime;
    }

    MintConfig public mintConfig;

    address public metadataRenderer;

    uint256 private constant MAX_OWNER_COUNT = 7000;

    uint256 private ownerCount = 0;

    event Set721TransferExempt(address exemptAddress);

    error MintNotStart();
    error MintFinished();

    constructor(
        address initialOwner_
    )
        ERC404("MintSwap404NFT", "MST", 18, 10000)
        Ownable(initialOwner_)
    {

    }

    modifier isSufficient() {
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

    function mint(uint numberOfTokens) external payable isSufficient {
        require(_publicMintedCount + numberOfTokens <= PUBLIC_SALE_COUNT, "public sale has ended");
        require(PUBLIC_SALE_PRICE * numberOfTokens <= msg.value, "Ether value sent is not correct");
        _mintERC20(_msgSender(), units * numberOfTokens);
        _publicMintedCount += numberOfTokens;
    }

    function setSelfERC721TransferExempt(address exemptAddress) external onlyOwner {
        _setERC721TransferExempt(exemptAddress, true);
    }

    function mintERC20ForExempt(address exemptAddress, uint256 amount) external onlyOwner {
        require(amount > 0 && amount <= MAX_OWNER_COUNT - ownerCount, "The maximum mint quantity cannot exceed 7000");
        _mintERC20(exemptAddress, amount * units);
        ownerCount += amount;
    }

    function setMintConfig(
        uint32 _startTime,
        uint32 _endTime
    ) external onlyOwner {
        require(_endTime > _startTime, "MUST(end time  > Start time)");
        mintConfig = MintConfig( _startTime, _endTime);
    }

}
