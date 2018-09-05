pragma solidity ^0.4.21;

import "openzeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @title DotSticker
 * DotSticker - a contract for Dot Wallet non-fungible Tokens.
 */
contract DotSticker is ERC721Token, Ownable {

    mapping (uint256 => address) internal contractOwner;
    
    uint internal mintingFee = 0.255 ether;

    struct Sticker {
        string title;
        address creator;
        uint64 created;
        uint256 edition;
    }

    Sticker[] public allstickers;

    constructor (string name, string symbol) public
        ERC721Token(name, symbol) 
    { }

    // ADMIN METHODS
    function setMintingFee(uint256 _price) public onlyOwner{
        mintingFee = _price;
    }

    /* Minting Functions */

    /**
    * @dev Mints a token to an address with a tokenURI.
    * @param _to address of the future owner of the token
    * @param _tokenURI token URI for the token
    */
    function mintCollectible(
            string _title,
            address _to, 
            string _tokenURI
            ) public onlyOwner {
        
        uint64 _birth = uint64(now);
        uint256 _edition = 0;
        
        Sticker memory _sticker = Sticker({title:_title, creator: msg.sender, created: _birth, edition: _edition});
        uint256 _newTokenId = allstickers.push(_sticker) - 1;

        _mint(_to, _newTokenId);
        _setTokenURI(_newTokenId, _tokenURI);
        
    }
    
    /**
    * @dev Clones a token based off of Edition Number
    * @param _to address of the future owner of the token
    * @param _tokenId token ID to clone
    */
    function cloneCollectible(address _to, uint256 _tokenId) public onlyOwner {
        
        Sticker storage _sticker = allstickers[_tokenId];
        
        uint64 _birth = uint64(now);
        uint256 _edition = _sticker.edition + 1;
        
        string storage _originalTitle = _sticker.title;
        address _originalCreator = _sticker.creator;
        
        Sticker memory _newSticker = Sticker({title: _originalTitle, creator: _originalCreator, created: _birth, edition: _edition});
        
        uint256 _newTokenId = allstickers.push(_newSticker) - 1;
        
        _mint(_to, _newTokenId);
        _setTokenURI(_newTokenId, tokenURI(_tokenId));
    }

    /**
    * @dev Mints a UserGenerated Collectible with Fee
    * @param _to address of the future owner of the token
    * @param _tokenURI token URI for the token
    */

    function mintUGCollectible(
            address _to,
            string _title,
            string _tokenURI
        ) public payable {

        //Require Publishing Fee
        require(msg.value == mintingFee);
        msg.sender.call.value(msg.value).gas(20317);
        // address(this).transfer(mintingFee);
        
        uint64 _birth = uint64(now);
        uint256 _edition = 0;

        Sticker memory _sticker = Sticker({title:_title, creator: msg.sender, created: _birth, edition: _edition});
        uint256 _newTokenId = allstickers.push(_sticker) - 1;

        _mint(_to, _newTokenId);
        _setTokenURI(_newTokenId, _tokenURI);
    }
    

    /**
    * @dev Removes a NFT from owner.
    * @param _owner Address from wich we want to remove the NFT.
     * @param _tokenId Which NFT we want to remove.
    */
    function burn(
        address _owner,
        uint256 _tokenId
    ) external onlyOwner {
        super._burn(_owner, _tokenId);
    }

    /**
    * @dev Sets token metadata URI.
    * @param _tokenId token ID
    * @param _tokenURI token URI for the token
    */
    function setTokenURI(
        uint256 _tokenId, string _tokenURI
    ) public onlyOwner {
        _setTokenURI(_tokenId, _tokenURI);
    }
    
    function getTokenURI(
        uint256 _tokenId
    ) public view returns (string){
       return tokenURI(_tokenId);
    }
    
    function getAllTokens() public view returns (uint256[]) {
        return allTokens;
    }
    
    function withdraw() public onlyOwner {
        address(owner).transfer(address(this).balance);
    }
    
    function contractBalance() public view returns (uint256){
        return address(this).balance;
    }
        
    function getMintingFee() public view returns (uint) {
        return mintingFee;
    }

}