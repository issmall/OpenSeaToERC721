// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";


contract OpenSeaSharedStorefront is ERC1155 {

    constructor() ERC1155("https://issmall.me/nft/json/{id}.json") {}

    function mint(address to, uint256 id, uint256 amount, bytes memory data) external payable {
        _mint(to, id, amount, data);
    }
}
