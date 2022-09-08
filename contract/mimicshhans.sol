// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;


import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";


contract OSS {
    function safeTransferFrom(address from, address to, uint256 tokenId, uint256 amount, bytes memory data) external {}
    function isApprovedForAll(address account, address operator) external returns (bool) {}
}


contract MimicShhans is ERC721 {

    address private _owner;
    address private _validator;
    string private _currentBaseURI;
    address private _OpenSeaAddr;
    address private _osRecycleAddr = address(0xdead);

    constructor() ERC721("Mimic Shhans", "MS") {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "Access Denied");
        _;
    }

    function setValidator(address addr) external onlyOwner {
        _validator=addr;
    }

    function setOSAddr(address addr) external onlyOwner {
        _OpenSeaAddr = addr;
    }

    function setRecycleAddr(address addr) external onlyOwner {
        _osRecycleAddr = addr;
    }

    function _baseURI() internal view override returns (string memory) {
        return _currentBaseURI;
    }

    function setBaseURI(string calldata baseURI) external onlyOwner {
        _currentBaseURI = baseURI;
    }

    function _messageToRecover(bytes memory packed) private pure returns (bytes32) {
        bytes32 hashedUnsignedMessage = keccak256(packed);
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        return keccak256(abi.encodePacked(prefix, hashedUnsignedMessage));
    }

    function _validSignature(bytes memory packed, bytes calldata signature) private view returns (bool isValid) {
        bytes32 message = _messageToRecover(packed);
        address addr = ECDSA.recover(message, signature);
        if (addr == _validator) {
            return true;
        }
    }

    function validate(address to, uint256 osId, uint256 msId, bytes calldata signature) external view returns (bool) {
        bytes memory packed = abi.encodePacked(to, osId, msId);
        return _validSignature(packed, signature);
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        string memory baseURI = _baseURI();
        return string(abi.encodePacked(baseURI, Strings.toString(tokenId), ".json"));
    }

    function mint(address to, uint256 tokenId, bytes calldata signature) external payable {
        require(to != address(0), "ERC721: mint to zero address");
        require(!_exists(tokenId), "ERC721: token already minted");
        require((tokenId > 9000 && tokenId <= 10000) || (tokenId > 10011 && tokenId <= 10020), "ERC721: token not exists");
        bytes memory packed = abi.encodePacked(to, tokenId);
        require(_validSignature(packed, signature), "ERC721: invalid signature");

        _safeMint(to, tokenId, "");
    }

    function convert(address to, uint256 osId, uint256 tokenId, bytes calldata signature) external payable {
        require(to != address(0), "ERC721: mint to zero address");
        require(!_exists(tokenId), "ERC721: token already minted");
        require(tokenId > 0 && tokenId <= 10020, "ERC721: token not exists");
        bytes memory packed = abi.encodePacked(to, osId, tokenId);
        require(_validSignature(packed, signature), "ERC721: invalid signature");

        require(OSS(_OpenSeaAddr).isApprovedForAll(msg.sender, address(this)), "Access Denied");

        OSS(_OpenSeaAddr).safeTransferFrom(msg.sender, _osRecycleAddr, osId, 1, "");
        _safeMint(to, tokenId, "");
    }
}
