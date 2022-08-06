// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.0.0/contracts/token/ERC721/ERC721.sol";

contract Auctions is ERC721 {
    using SafeMath for uint;

    constructor() ERC721("Crowdfunding", "CWD") public {}

    struct Token {
        address creator;
        string name;
        string description;
        address beneficiary;    
    
        bool eventComplete;
        uint totalDonations;
        address biggestDonor;

        mapping(address => uint) contributions;
    }

    mapping(uint => Token) public tokenCollection;
    event donations(uint tokenId, address donor, uint256 amount);
    
    function createToken(string memory name, string memory description, address beneficiary, string memory tokenURI) public {
        uint256 tokenId = totalSupply();

        _mint(msg.sender, tokenId);
        _setTokenURI(tokenId, tokenURI);

        tokenCollection[tokenId] = Token(msg.sender, name, description, beneficiary, false, 0, msg.sender);
    }

    function end(uint tokenId) public {
        require(msg.sender == tokenCollection[tokenId].creator);
        require(tokenCollection[tokenId].eventComplete == false);
        Token storage token = tokenCollection[tokenId];

        payable(token.beneficiary).transfer(token.totalDonations);
        _transfer(token.creator, token.biggestDonor, tokenId);

        token.eventComplete = true;
    }

    function donate(uint tokenId) public payable {
        tokenCollection[tokenId].totalDonations += msg.value;
        tokenCollection[tokenId].contributions[msg.sender] += msg.value;

        if (tokenCollection[tokenId].contributions[msg.sender] > tokenCollection[tokenId].contributions[tokenCollection[tokenId].biggestDonor]) {
            tokenCollection[tokenId].biggestDonor = msg.sender;
        }
    
        emit donations(tokenId, msg.sender, msg.value);
    }

    function viewToken(uint tokenId) public view returns(address, string memory, string memory, address, bool, uint, address) {
        Token storage token = tokenCollection[tokenId];

        return (token.creator, token.name, token.description, token.beneficiary, token.eventComplete, token.totalDonations, token.biggestDonor);
    }
}