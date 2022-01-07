//We are using CHAINLINK oracle for randomness of choice 

pragma solidity 0.6.6;

import "openzeppelin/contracts/token/ERC721/ERC721.sol";
//this helps to create randomness , cryptographic ,scarce NFT
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

//Multiple inheritance
contract FighterJetNft is ERC721 , VRFConsumerBase{

    //variable for tracking number of tokens
    uint256 public tokenCounter;

    //custom datastructure for storing choices of jets
    enum Jets("Sukhoi","Mig","Rafale")
    
    //address->requestId->request->tokenID->tokenURI
    
    //mapping for keeping track of which address is making which request
    mapping (bytes32=>address)public requestIdtoSender;
    
    //mapping for keeping track of which request is interacting to whichtokenURI
    mapping (bytes32 => string) public requestIdtotokenURI;
    
    //mapping for keeping track of which tokenID is getting  which jet
    mapping(uint256=>Jets) public newtokenIDtoJets;
    
    //mapping for keeping track of which requestID is linked to  which tokenId
    mapping(bytes32 => uint256) public requestIdToTokenId;
    
    event requestedCollectible(bytes32 indexed requestId); 

    //for generating randomResult
    bytes32 internal keyHash;
    uint256 internal fee;
    uint256 internal randomResult;

    //Chainlink VRF to consume randomness in smart contracts
    //LinkToken because we will fee oracle gas
    //keyHash for randomness
    //we are inheriting constructor of VRFConsumerBase and ERC721
    
    constructor (address _VRFCordinator,address _LinkToken,bytes32 _keyHash)
    public
    VRFConsumerBase(_VRFCordinator,_LinkToken)
    ERC721("JetCoin","~>"){
        tokenCounter=0;
        keyHash= _keyHash;
        //oracle gas fee
        fee= 0.1 *10 **18;

    }

    function createJetTokens(string memeory _tokenURI,uint256 userProvidedSeed) public returns(bytes32){

        //requestRandomness() inherited from VRFConsumerBase
        bytes32 requestId = requestRandomness(keyHash,fee,userProvidedSeed);
        requestIdToTokenURI[requestId] = tokenURI;
        emit requestedCollectible(requestId);
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomNumber) internal override {
        address jetOwner= requestIdtoSender[requestId];
        string memory tokenURI = requestIdtotokenURI[requestId];
        uint256 newtokenID= tokenCounter;
        _safeMint(jetOwner,newtokenID);
        _setTokenURI(newtokenID,tokeURI);

        //instance 
        //returns 1 of the 3 options
        Jets jet = Jets(randomNumber%3);
        newtokenIDtoJets[newtokenID]=jet;
        requestIdToTokenId[requestId] = newItemId;
        tokenCounter = tokenCounter + 1;
        
    }
}
