//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "ERC404.sol";

contract MintSwap404NFT is Ownable, ERC404 {
    using Strings for uint256;
    uint8 constant _decimals = 18;
    uint256 _maxTotalSupplyERC721 = 10000;

    uint256 public constant PUBLIC_SALE_PRICE = 0.04 ether; //0.04 ETH

    uint256 public constant PUBLIC_SALE_COUNT = 3000; //public sale count

    uint256 public _publicMintedCount = 0;

    uint256 public _publicSaleStartTime;// public sale start time

    uint256 public _publicSaleEndTime;// public sale end time

    event Set721TransferExempt(address exemptAddress);

    string private constant __NAME = "MintSwap404NFT";
    string private constant __SYM = "MST";

    constructor(
        address initialOwner_,
        address initialMintRecipient_
    )
        ERC404(__NAME, __SYM, _decimals)
        Ownable(initialOwner_)
    {
        // Do not mint the ERC721s to the initial owner, as it's a waste of gas.
        // _mintERC20(initialMintRecipient_, _maxTotalSupplyERC721 * units);
        // _publicSaleStartTime = block.timestamp;
    }

    function tokenURI(uint256 id_) public pure override returns (string memory) {
        return string.concat("https://example.com/token/", Strings.toString(id_));
    }

    function mint(uint numberOfTokens) public payable {
        uint256 _saleStartTime = uint256(_publicSaleStartTime);
        uint256 _saleEndTime = uint256(_publicSaleEndTime);

        require(_saleStartTime != 0 && block.timestamp >= _saleStartTime, "public sale has not started yet");
        require(block.timestamp <= _saleEndTime, "public sale has ended");
        require(_publicMintedCount.add(numberOfTokens) <= PuPUBLIC_SALE_COUNT, "public sale has ended");
        require(PUBLIC_SALE_PRICE.mul(numberOfTokens) <= msg.value, "Ether value sent is not correct");

        address sender = _msgSender();
        for (uint256 i; i < numberOfTokens; i++) {
            _mintERC20(sender, units);
        }
        _publicMintedCount += numberOfTokens;
    }

    // _publicSaleStartTime setter，onlyOwner
    function setPublicSaleStartAndEndTime(uint32 statTime, uint32 endTime) external onlyOwner {
        _publicSaleStartTime = statTime;
        _publicSaleEndTime = endTime;
    }

    function setSelfERC721TransferExempt(address exemptAddress) external onlyOwner {
        // _setERC721TransferExempt(exemptAddress, true);
        _erc721TransferExempt[target_] = true;
    }

    function mintERC20ForExempt(address exemptAddress, uint256 amount) external onlyOwner {
        _mintERC20(exemptAddress, amount);
    }

}
