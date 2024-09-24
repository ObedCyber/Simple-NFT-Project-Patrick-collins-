// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {Test, console} from "forge-std/Test.sol";

contract MoodNft is ERC721 {
    //errors
    error MoodNft_CantFlipMoodIfNotOwner();

    uint256 private s_tokenCounter;
    string private s_sadSvgImageUri;
    string private s_happySvgImageUri;

    enum Mood {
        HAPPY,
        SAD
    }
    mapping(uint256 => Mood) private s_tokenIdToMood;

    constructor(
        string memory sadSvgImageURI,
        string memory happySvgImageURI
    ) ERC721("Mood NFT", "MN") {
        s_tokenCounter = 0;
        s_sadSvgImageUri = sadSvgImageURI;
        s_happySvgImageUri = happySvgImageURI;
    }

    function mintNft() public {
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenIdToMood[s_tokenCounter] = Mood.HAPPY;
        s_tokenCounter++;
    }

    function flipMood(uint256 tokenId) public {
        // only want the NFT owner to be able to change the mood
        if (
            getApproved(tokenId) != msg.sender && ownerOf(tokenId) != msg.sender
        ) {
            revert MoodNft_CantFlipMoodIfNotOwner();
        }
        
        if (s_tokenIdToMood[tokenId] == Mood.HAPPY) {
            s_tokenIdToMood[tokenId] = Mood.SAD;
            console.log(uint256(s_tokenIdToMood[tokenId]));
        } else {
            s_tokenIdToMood[tokenId] = Mood.HAPPY;
            console.log(uint256(s_tokenIdToMood[tokenId]));

        }
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        string memory imageURI;
        if (s_tokenIdToMood[tokenId] == Mood.SAD){
            imageURI = s_sadSvgImageUri;
            console.log(uint256(s_tokenIdToMood[tokenId]));

        }
        if (s_tokenIdToMood[tokenId] == Mood.HAPPY) {
            imageURI = s_happySvgImageUri;
            console.log(uint256(s_tokenIdToMood[tokenId]));

        } 

        // to get the encoded format of our metadata to make it in a  url form
        return
            string(
                abi.encodePacked(
                    _baseURI(),
                    Base64.encode(
                        bytes( // we need to convert to bytes before we can use openzepplin base64 encode. It's in the docs.
                            abi.encodePacked(
                                '{"name": "',
                                name(),
                                '","description": "An NFT that reflects the owners mood.", "attributes":[{"trait_type": "moodiness", "value": 100}], "image": "',
                                imageURI,
                                '"}'
                            )
                        )
                    )
                )
            );
    }
}
