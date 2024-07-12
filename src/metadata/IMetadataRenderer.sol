// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IMetadataRenderer {
    function tokenURI(uint256 id) external view returns (string memory);
}
