// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./interfaces/IERC4907.sol";

contract GameToken is
    Initializable,
    ERC721Upgradeable,
    IERC4907,
    OwnableUpgradeable
{
    struct User {
        address userAddress;
        uint256 expires;
    }

    uint256 private _tokenIdCounter;
    mapping(uint256 => User) private _tokenUsers;

    error AlreadyRented();
    error CurrentlyRented();
    error InvalidExpireTime();

    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) public initializer {
        __ERC721_init("GameToken", "GTK");
        __Ownable_init(initialOwner);
    }

    function setUser(
        uint256 tokenId_,
        address userAddress_,
        uint64 expires_
    ) public override {
        _checkAuthorized(_ownerOf(tokenId_), msg.sender, tokenId_);
        User storage user = _tokenUsers[tokenId_];
        require(user.expires <= block.timestamp, AlreadyRented());
        require(uint256(expires_) > block.timestamp, InvalidExpireTime());
        user.userAddress = userAddress_;
        user.expires = expires_;
        emit UpdateUser(tokenId_, userAddress_, expires_);
    }

    function userOf(uint256 tokenId_) public view override returns (address) {
        User storage user = _tokenUsers[tokenId_];
        if (user.expires >= block.timestamp) return user.userAddress;
        else return ownerOf(tokenId_);
    }

    function userExpires(
        uint256 tokenId_
    ) public view override returns (uint256) {
        return _tokenUsers[tokenId_].expires;
    }

    function safeMint(address to) public onlyOwner returns (uint256) {
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;
        _safeMint(to, tokenId);
        return tokenId;
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        User storage user = _tokenUsers[tokenId];
        require(user.expires < block.timestamp, CurrentlyRented());
        super.transferFrom(from, to, tokenId);
        delete _tokenUsers[tokenId];
        emit UpdateUser(tokenId, address(0), 0);
    }
}
