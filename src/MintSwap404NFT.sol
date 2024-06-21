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

    event BaseUriUpdate(string uri);
    event WebsiteUrlUpdate(string uri);
    event ContractUriUpdate(string uri);
    event Set721TransferExempt(address txExempt);
    event TokensStaked(address indexed owner, uint256[] tokenIds);


    string private constant __NAME = "MintSwap404NFT";
    string private constant __SYM = "MST";

    string private _websiteUri;

    string public _baseUri;
    string private _contractUri;

    address private constant _uniswapV3Router = 0xE592427A0AEce92De3Edee1F18E0157C05861564;

    constructor(
        address initialOwner_,
        address initialMintRecipient_
    )
        ERC404(__NAME, __SYM, _decimals)
        Ownable(initialOwner_)
    {
        // Do not mint the ERC721s to the initial owner, as it's a waste of gas.
        _mintERC20(initialMintRecipient_, _maxTotalSupplyERC721 * units);
        _baseUri = "ipfs://QmaZayMhEmhKKqDHoXHMMd1SMic5wpXvJWa2KeyfEz8RM7/";
        _websiteUri = "https://PORTAL404.io";

        _contractUri = string(
            abi.encodePacked(
                '{"name": "Portal-404","description": A collection of ',
                _maxTotalSupplyERC721.toString(),
                ' ERC-404 Tokens enhanced with ERC-5169 + TokenScript"","image": "ipfs://Qmf8Qi6oapx8sce1kPa6aiFUMzCpm869D1RpeGYinEwtgo"}'
            )
        );

        _publicSaleStartTime = block.timestamp;
    }

    function contractURI() public view returns (string memory) {
        return _contractUri;
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        uint8 seed = uint8(bytes1(keccak256(abi.encodePacked(id))));
        string memory image;
        string memory color;

        if (seed <= 100) {
            image = "blue.gif";
            color = "Blue";
        } else if (seed <= 150) {
            image = "green.gif";
            color = "Green";
        } else if (seed <= 200) {
            image = "yellow.gif";
            color = "Yellow";
        } else if (seed <= 230) {
            image = "indigo.gif";
            color = "Indigo";
        } else if (seed <= 248) {
            image = "red.gif";
            color = "Red";
        } else {
            image = "obsidian.gif";
            color = "Obsidian";
        }

        return
            string(
                abi.encodePacked(
                    '{"name": "Portal-404 #',
                    id.toString(),
                    '","description":"A collection of ',
                    _maxTotalSupplyERC721.toString(),
                    " ERC-404 Tokens enhanced with ERC-5169 & TokenScript",
                    '","external_url":"',
                    _websiteUri,
                    '","image":"',
                    _baseUri,
                    image,
                    '","attributes":[{"trait_type":"Color","value":"',
                    color,
                    '"}]}'
                )
            );
    }

    function setWebsiteUrl(string memory newUri) public onlyOwner {
        _websiteUri = newUri;
        emit WebsiteUrlUpdate(newUri);
    }

    function setBaseURI(string memory newUri) public onlyOwner {
        _baseUri = newUri;
        emit BaseUriUpdate(newUri);
    }

    function setContractURI(string memory newUri) public onlyOwner {
        _contractUri = newUri;
        emit ContractUriUpdate(newUri);
    }

    // Supply ERC5159 and ERC404 type
    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC5169, ERC404) returns (bool) {
        return
            ERC404.supportsInterface(interfaceId);
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
