// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/utils/Strings.sol";
import "../node_modules/@openzeppelin/contracts/utils/Base64.sol";

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
    ) public view override returns (string memory) {
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
                    Strings.toString(tokenID - ID_ENCODING_PREFIX),  // tokenID - ID_ENCODING_PREFIX
                    '",',
                    '"description": "',
                    description,
                    '",',
                    '"image": "',
                    imageURI,
                    Strings.toString(tokenID),
                    '"}'
                )
            );
    }

    function setName(string memory _newName) external onlyOwner {
        name = _newName;
    }

    function setImageUri(string memory _newURI) external onlyOwner {
        imageURI = _newURI;
    }

    function setDescription(string memory _description) external onlyOwner {
        description = _description;
    }
}