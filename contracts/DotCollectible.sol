pragma solidity ^0.4.21;

import "openzeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @title DotCollectible
 * DotCollectible - a contract for Dot Wallet non-fungible Tokens.
 */
contract DotCollectible is ERC721Token, Ownable {
    
    mapping (uint256 => address) internal contractOwner;
    mapping (uint256 => uint) private tokenEdition;
    mapping (uint256 => uint256) private tokenOriginator;
    mapping (uint256 => uint256) private tokenGifter;
    mapping (string => uint256) private apiIDMap;

    uint private mintingFee = 0.1 ether;
    uint private giftingFee = 0.1 ether;
    
    uint256 private tokenBalance = 0;
    uint256 private bankBalance = 0;
    
    constructor(string _name, string _symbol) 
        public ERC721Token(_name, _symbol) { 
    }

    struct Sticker {
        uint generation;
        uint edition;
        uint256 value;
        string uniqueID;
    }

    Sticker[] public allstickers;

    // ADMIN METHODS
    function setMintingFee(uint256 _price) public onlyOwner{
        mintingFee = _price;
    }
    
    function setGiftinFee(uint256 _price) public onlyOwner{
        giftingFee = _price;
    }

    /* Minting Functions */
    /**
    * @dev Mints a token to an address with a tokenURI.
    * @param _to address of the future owner of the token
    */

    function mintCollectible (
        address _to,
        string _tokenURI,
        string _uniqueID
        ) public {
        
        uint _edition = 0;
        uint _generation = 0;
        
        Sticker memory _sticker = Sticker({
            generation: _generation,
            edition: _edition,
            value: 0,
            uniqueID:_uniqueID
        });
        
        uint256 _newTokenId = allstickers.push(_sticker) - 1;
        tokenOriginator[_newTokenId] = _newTokenId; // GEN0
        tokenGifter[_newTokenId] = _newTokenId;
        
        tokenEdition[_newTokenId] = _edition;
        apiIDMap[_uniqueID] = _newTokenId; 
        
        _mint(_to, _newTokenId);
        _setTokenURI(_newTokenId, _tokenURI);
    }
    
    // /**
    // * @dev Gifts a token based off of Edition and Generation Number
    // * @param _to address of the future owner of the token
    // * @param _tokenId token ID to clone
    // */
    // function giftCollectible(uint256 _tokenId, address _to) public payable {
        
    //     require(isApprovedOrOwner(msg.sender, _tokenId), "NON Token Owner");

    //     //Get old sticker
    //     Sticker storage _sticker = allstickers[_tokenId];
    //     uint _edition = _sticker.edition + 1;
    //     uint _generation = _sticker.generation + 1;
        
    //     //If gen 0 do not require gifting fee
    //     if (_sticker.generation > 0) {
    //         require(msg.value >= giftingFee, "MSG Value not sufficient.");
    //         msg.sender.transfer(msg.value);
    //     }
        
    //     tokenEdition[_tokenId] = _edition;
        
    //     Sticker memory _newSticker = Sticker({
    //         generation: _generation,
    //         edition: _edition,
    //         value: 0
    //     });
        
    //     uint256 _newTokenId = allstickers.push(_newSticker) - 1;
        
    //     //Assign Generation and Gifting
    //     updateTokenGenEdition(_tokenId, _newTokenId);
        
    //     _mint(_to, _newTokenId);
    //     _setTokenURI(_newTokenId, tokenURI(_tokenId));
        
    // }
    
    function updateTokenGenEdition(uint256 _tokenId, uint256 _newTokenId) internal {
        
        if (exists(_tokenId) == true) {
            //Assign Parent Token ID to New Token
            tokenGifter[_newTokenId] = _tokenId;
        
            uint256 _tokenZ = tokenOriginator[_tokenId];
            updateTokenValue(_tokenZ, msg.value/100);
        
            uint256 _tokenX = tokenGifter[_tokenId];
            updateTokenValue(_tokenX, msg.value/10);
        }

    }
    
    function getTokenValue(uint256 _tokenId) public view returns(uint256) {
        Sticker storage sticker = allstickers[_tokenId];
        return sticker.value;
    }
    
    function topupTokenValue(uint256 _tokenId) public payable {
        require(isApprovedOrOwner(msg.sender, _tokenId), "NON Token Owner");
        
        if (msg.value > 0){
            msg.sender.transfer(msg.value);
            updateTokenValue(_tokenId, msg.value);
        }
    }
    
    function updateTokenValue(uint256 _tokenId, uint256 _value) internal {
        require(isApprovedOrOwner(msg.sender, _tokenId), "NON Token Owner");
        
        Sticker storage sticker = allstickers[_tokenId];
        sticker.value += _value;
        tokenBalance += _value;
    }
    
    function drainTokenValue(uint256 _tokenId) internal {
        Sticker storage sticker = allstickers[_tokenId];
        tokenBalance -= sticker.value;
        sticker.value = 0;
    }
   
    function burnToken(uint256 _tokenId) public {
        drainTokenValue(_tokenId);
        _burn(msg.sender, _tokenId);
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
    
    /**
    * @dev Allows user to redeem balance of Token.
    * @param _tokenId token ID of user
    */
    function redeem(uint256 _tokenId) public {
        
        require(isApprovedOrOwner(msg.sender, _tokenId), "NON Token Owner");
        
        uint256 val = getTokenValue(_tokenId);
        
        if (val <= tokenBalance) {
            address(msg.sender).transfer(val);
            drainTokenValue(_tokenId);
        }

    }
    
    /**
    * @dev Allows onlyOwner to withdraw from contract balance.
    * @param value value to withrdraw
    */
    function withdraw(uint256 value) public onlyOwner {
        if (value <= contractBankBalance()){
            address(owner).transfer(value);
        }
    }

    function contractBalance() public view returns (uint256){
        return address(this).balance;
    }
    
    function contractBankBalance() public view returns (uint256){
        return address(this).balance - tokenBalance;
    }
        
    function getMintingFee() internal view returns (uint) {
        return mintingFee;
    }
    
    function getGiftinFee() internal view returns (uint) {
        return giftingFee;
    }
    
    function getStickerGifter(uint256 _tokenId) view public returns (uint) {
        return tokenGifter[_tokenId];
    }
    
    function getStickerOriginator(uint256 _tokenId) view public returns (uint) {
        return tokenOriginator[_tokenId];
    }
    
    function getAPITokenId(string _uniqueID) view public returns (uint256) {
        return apiIDMap[_uniqueID];
    }

}