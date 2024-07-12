// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

import "./IMetadataRenderer.sol";

contract MetadataRenderer is IMetadataRenderer, Ownable {

    string private imageURI;
    string private name;
    string private description;

    uint256 public constant ID_ENCODING_PREFIX = 1 << 128;

    constructor(
        string memory _defaultName,
        string memory _description,
        string memory _defaultImageURI
    ) Ownable(_msgSender()) {
        name = _defaultName;
        description = _description;
        imageURI = _defaultImageURI;
    }

    function tokenURI(
        uint256 tokenID
    ) external view override returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(bytes(tokenURIJSON(tokenID)))
                )
            );
    }

    function tokenURIJSON(uint256 tokenID) public view returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "{",
                    '"name": "',
                    name,
                    " #",
                    Strings.toString(tokenID - ID_ENCODING_PREFIX),
                    '",',
                    '"description": "',
                    description,
                    '",',
                    '"image": "',
                    imageURI,
                    Strings.toString(tokenID - ID_ENCODING_PREFIX),
                    ".png",
                    '"}'
                )
            );
    }

    function setName(string calldata _newName) external onlyOwner {
        name = _newName;
    }

    function setImageUri(string calldata _newURI) external onlyOwner {
        imageURI = _newURI;
    }

    function setDescription(string calldata _description) external onlyOwner {
        description = _description;
    }
    
}