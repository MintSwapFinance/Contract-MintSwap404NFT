//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {ERC404} from "ERC404.sol";

contract MintSwap404NFT is Ownable, ERC404 {
    using Strings for uint256;
    uint8 constant _decimals = 18;
    uint256 _maxTotalSupplyERC721 = 10000;

    uint256 public constant PUBLIC_SALE_PRICE = 40000000000000000; //0.04 ETH

    uint256 public constant PUBLIC_SALE_COUNT = 3000; //public sale count

    uint256 public _publicMintedCount = 0;

    uint256 public constant PUBLIC_SALE_TIME = 43200 minutes;// public sale time 30 days

    uint256 public _publicSaleStartTime;// public sale start time

    mapping(address => uint256[]) public stakedAddressInfo;

    event Set721TransferExempt(address txExempt);
    event TokensStaked(address indexed owner, uint256[] tokenIds);


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
        _mintERC20(initialMintRecipient_, _maxTotalSupplyERC721 * units);

        _publicSaleStartTime = block.timestamp;
    }

    function tokenURI(uint256 id_) public pure override returns (string memory) {
        return string.concat("https://example.com/token/", Strings.toString(id_));
    }

    function mint(uint numberOfTokens) public payable {
        uint256 _saleStartTime = uint256(_publicSaleStartTime);
        require(_saleStartTime != 0 && block.timestamp >= _saleStartTime, "public sale has not started yet");
        require(block.timestamp - _saleStartTime <= PUBLIC_SALE_TIME, "public sale has ended");
        require(_publicMintedCount.add(numberOfTokens) <= PuPUBLIC_SALE_COUNT, "public sale has ended");
        require(PUBLIC_SALE_PRICE.mul(numberOfTokens) <= msg.value, "Ether value sent is not correct");

        address sender = _msgSender();
        for (uint256 i; i < numberOfTokens; i++) {
            _mintERC20(sender, units);
        }
        _publicMintedCount += numberOfTokens;
    }

    // _publicSaleStartTime setter，onlyOwner
    function setPublicSaleStartTime(uint32 timestamp) external onlyOwner {
        _publicSaleStartTime = timestamp;
    }

    function stake(uint256[] calldata tokenIds) external {
        require(tokenIds.length > 0, "MP: Staking zero tokens");
        address sender = _msgSender();
        for (uint256 i = 0; i < tokenIds.length; ) {
            transferFrom(sender, address(this), tokenIds[i]);
            unchecked {
                ++i;
            }
        }
        emit TokensStaked(owner, tokenIds);
    }
}
