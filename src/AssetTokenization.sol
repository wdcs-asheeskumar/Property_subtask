// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * @title PropertyToken
 * @author Ashees Kumar
 * @notice This contract is created to mint Property tokens with unique name and symbol as per the desire of the owner.
 */

contract PropertyToken is ERC20 {
    constructor(
        string memory _tokenName,
        string memory _tokenSymbol
    ) ERC20("_tokenName", "_tokenSymbol") {
        _tokenName = _tokenName;
        _tokenSymbol = _tokenSymbol;
    }

    /// @dev function to mint property token
    /// @param to address at which tokens have to be minted
    /// @param amount amount of token that has to be minted
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    /// @dev function to transfer property token from one address to another
    /// @param from address from which the property tokens has to be send, sender address
    /// @param to address to which the property tokens has to be minted, receiver address
    /// @param value amount of property token that has to be transferred to the receiver
    function transferToken(address from, address to, uint256 value) public {
        _transfer(from, to, value);
    }

    /// @dev function to give approval to other address to spend property tokens
    /// @param owner the owner of the address who is owning the property token and giving approval
    /// @param spender the address which is being approved to spend the property token
    /// @param value amount of property token approval given from owner to spender to spend.
    function approveToken(
        address owner,
        address spender,
        uint256 value
    ) public {
        _approve(owner, spender, value);
    }
}

/**
 * @title UsdtMock
 * @author Ashees Kumar
 * @notice This contract is created to mint Mock USDT tokens for the investor
 */

contract UsdtMock is ERC20 {
    constructor() ERC20("MockUsdt", "USDT") {}

    /// @dev function to mint token and transfer it from investor to owner
    /// @param investor the address on which the mock USDT tokens have to be minted
    /// @param owner owner address to whom the investor will transfer the mock USDT tokens
    /// @param value the amount of mock USDT tokens that will be minted on investor's address and then transfered to the owner
    function mintToken(address investor, address owner, uint256 value) public {
        _mint(investor, value);
        _transfer(investor, owner, value);
    }

    /// @dev function to check the approval
    /// @param owner the owner of the mock USDT token which has approved the spender with mock USDT token
    /// @param spender the spender of the mock USDT token which has been approved by the owner of the token
    /// @return uint256 the amount of allowance of spender
    function checkApproval(
        address owner,
        address spender
    ) public view returns (uint256) {
        return (allowance(owner, spender));
    }

    /// @dev function to transfer funds from investor to owner as well as from owner to investor
    /// @param investor the address of the account who owns the mock USDT token
    /// @param owner the address of the account to whom the mock USDT token will be trasnferred
    /// @param value the amount of mock USDT token which will be transferred
    function transferFunds(
        address investor,
        address owner,
        uint256 value
    ) public {
        _transfer(investor, owner, value);
    }

    /// @dev function to check the USDT balance of the user.
    /// @param owner the address of the account whose balance has to be fetched
    /// @return uint256 balance of the account
    function checkBalance(address owner) public view returns (uint256) {
        return balanceOf(owner);
    }
}

/**
 * @title PropertyNFT
 * @author Ashees Kumar
 * @notice This contract is created to mint Property NFT when the owner lists his property.
 */

contract PropertyNFT is ERC721 {
    constructor() ERC721("PropertyNFT", "PNFT") {}

    /// @dev function to mint NFT for the owner
    /// @param to the address at which the NFT has to be minted
    /// @param tokenId the tokenId of the NFT that has to be minted
    function safeMint(address to, uint256 tokenId) public {
        _safeMint(to, tokenId);
    }

    /// @dev function to check the owner of the NFT
    /// @param _tokenId the token id of the NFT whose owner has to be checked
    /// @return address of the owner of the NFT
    function checkOwner(uint256 _tokenId) public view returns (address) {
        return _ownerOf(_tokenId);
    }

    /// @dev function to burn NFT
    /// @param _tokenId the token id of the NFT that has to be burned
    function burnNFT(uint256 _tokenId) public {
        _burn(_tokenId);
    }
}

/**
 * @title AssetTokenization
 * @author Ashees Kumar
 * @notice This contract is the main contract for performing asset tokenization allowing the owners to
 * @notice list their assets and allowing the investors to invest in those assets.
 */

contract AssetTokenization {
    /// @dev struct to store the data of property.
    /// @param propertyId to store the unique Id of the property.
    /// @param propertyOwnerAddress to store the address of the property owner.
    /// @param valueOfProperty to store the overall value of the asset.
    /// @param valueAvailableFromInvestment to store the value of property available for investment.
    /// @param annualEarning to store the annual earning from the property.
    /// @param valueCurrentlyAvailable to store the value currently available for investing.
    /// @param noOfInvestors to store the total number of investors for a particular property.
    struct PropertyOwnerDetails {
        uint256 propertyId; // 1
        address propertyOwnerAddress;
        uint256 valueOfProperty; // 50000
        uint256 valueAvailableForInvestment; // 20000
        uint256 annualEarning; // 24000
        uint256 valueCurrentlyAvailable; /// @dev Amount of value of property currently remaining.
        uint256 noOfInvestors;
    }

    /// @dev struct to store the data and investment record of the investor
    /// @param propertyId to store an array of all property ids
    /// @param amountInvested to store the amount invested in each property corresponding to their propertyId
    /// @param numberOfPropertier to store the total number of properties in which the investor has invested
    struct InvestorsData {
        uint256[] propertyId;
        uint256[] amountInvested;
        uint256 numberOfProperties;
    }

    /// @dev struct to store the data and properties record of the owner
    /// @param propertyId to store an array of all the property ids of all the properties owned by the owner.
    /// @param NftId to store the NFT ids of all the properties owned by the owner corresponding to their property id.
    /// @param numberOfProperties to store the total number of properties owned by the owner.
    struct OwnersData {
        uint256[] propertyId;
        uint256[] NftId;
        uint256 numberOfProperties;
    }

    /// @dev mapping for keeping tract of all the property and there details.
    mapping(uint256 => PropertyOwnerDetails) public propertyDetailsMapping;

    /// @dev mapping for keeping the record of listed properties
    mapping(uint256 => bool) public listedProperties;

    /// @dev mapping to keep record of the investor has invested in certain property or not.
    mapping(uint256 => mapping(address => bool)) public investmentRecords;

    /// @dev mapping to keep record of the amount of investment done by the investor in a particular property.
    mapping(uint256 => mapping(address => uint256))
        public investmentAmountRecords;

    /// @dev mapping to keep record of the time at which the investor has invested on a property
    mapping(uint256 => mapping(address => uint256)) public investmentTimeRecord;

    /// @dev mapping to keep record  of the investor's investment data
    mapping(address => InvestorsData) public investorsDataMapping;

    /// @dev mapping to keep record  of the investor's investment data
    mapping(address => OwnersData) public ownersDataMapping;

    /// @dev mapping for keeping record of property token name
    mapping(uint256 => string) public PropertyTokenName;

    /// @dev mapping for keeping record of property token symbol
    mapping(uint256 => string) public PropertyTokenSymbol;

    /// @dev time period at which the rent will be paid to the investor
    uint256 private timeFrame = 30 days;
    uint256 public id = 0;

    /// @dev emits when the property is listed
    event ListPropertyInfo(
        uint256 _id,
        address _ownerAddress,
        uint256 _valueOfProperty,
        uint256 _valueAvailableForInvestment,
        uint256 _annualEarning
    );

    /// @dev emits when an investor invests in some property.
    event InvestmentRecord(
        uint256 _propertyId,
        uint256 _amountToInvest,
        uint256 _investmentTimeRecord,
        bool _investmentStatus
    );

    UsdtMock public usdtMock;

    PropertyNFT public propertyNFT;

    PropertyToken public propertyToken;

    constructor(address _usdtMock, address _propertyNFT) {
        usdtMock = UsdtMock(_usdtMock);
        propertyNFT = PropertyNFT(_propertyNFT);
    }

    /// @dev function for the owner to list his property.
    /// @param _valueOfProperty provide the total value of property of the owner
    /// @param _valueAvailableForInvestment provide the total value of property available for investment
    /// @param _annualEarning provide the total annual earning of the owner from the property
    /// @param _tokenName provide the name of the ERC20 property token which will be minted at the owner's address
    /// @param _tokenSymbol provide the symbol of the ERC20 property token which will be minted at the owner's address
    function listProperty(
        uint256 _valueOfProperty,
        uint256 _valueAvailableForInvestment,
        uint256 _annualEarning,
        string memory _tokenName,
        string memory _tokenSymbol
    ) public {
        require(msg.sender != address(0), "Invalid address");
        require(_valueOfProperty > 0, "Invalid value of property");
        require(
            _valueAvailableForInvestment <= _valueOfProperty &&
                _valueAvailableForInvestment > 0,
            "Invalid value available for investment"
        );
        require(listedProperties[id] == false, "Property allready listed");

        id = id + 1;

        propertyDetailsMapping[id].propertyId = id;
        propertyDetailsMapping[id].propertyOwnerAddress = msg.sender;
        propertyDetailsMapping[id].valueOfProperty = _valueOfProperty;
        propertyDetailsMapping[id]
            .valueAvailableForInvestment = _valueAvailableForInvestment;
        propertyDetailsMapping[id]
            .valueCurrentlyAvailable = _valueAvailableForInvestment;
        propertyDetailsMapping[id].annualEarning = _annualEarning;
        listedProperties[id] = true;

        propertyToken = new PropertyToken(_tokenName, _tokenSymbol);
        propertyToken.mint(msg.sender, _valueOfProperty);
        propertyNFT.safeMint(msg.sender, id);

        ownersDataMapping[msg.sender].propertyId.push(id);
        ownersDataMapping[msg.sender].NftId.push(id);
        uint256 temp = ownersDataMapping[msg.sender].propertyId.length;
        ownersDataMapping[msg.sender].numberOfProperties = temp;

        PropertyTokenName[id] = _tokenName;
        PropertyTokenSymbol[id] = _tokenSymbol;

        emit ListPropertyInfo(
            id,
            msg.sender,
            _valueOfProperty,
            _valueAvailableForInvestment,
            _annualEarning
        );
    }

    /// @dev function to check the current status of the property.
    /// @param _idNumber provide the property id of the property whose details are needed
    /// @return address of the owner of the property
    /// @return uint256 of the total value of the property
    /// @return uint256 of the total value currently available for the property
    /// @return uint256 of the annual earning of the owner from the property
    function checkingProperty(
        uint256 _idNumber
    ) public view returns (address, uint256, uint256, uint256) {
        require(
            listedProperties[_idNumber] == true,
            "Property not listed or has been de-listed"
        );
        return (
            propertyDetailsMapping[_idNumber].propertyOwnerAddress,
            propertyDetailsMapping[_idNumber].valueOfProperty,
            propertyDetailsMapping[_idNumber].valueCurrentlyAvailable,
            propertyDetailsMapping[_idNumber].annualEarning
        );
    }

    /// @dev function for the investor to invest in the property
    /// @param _propertyId provide the property id of the property on which the investor has to invest.
    /// @param _amountToInvest the amount of investment the investor has to do in property.
    function investInProperty(
        uint256 _propertyId,
        uint256 _amountToInvest
    ) public {
        require(
            listedProperties[_propertyId] == true,
            "Property not listed or has been de-listed"
        );
        require(
            _amountToInvest <=
                propertyDetailsMapping[_propertyId].valueCurrentlyAvailable,
            "Amount more than the available value of investment"
        );
        require(
            propertyDetailsMapping[_propertyId].valueCurrentlyAvailable > 0,
            "No more investment in this property possible"
        );

        propertyDetailsMapping[_propertyId].valueAvailableForInvestment =
            propertyDetailsMapping[_propertyId].valueAvailableForInvestment -
            _amountToInvest;

        propertyDetailsMapping[_propertyId].noOfInvestors =
            propertyDetailsMapping[_propertyId].noOfInvestors +
            1;

        propertyDetailsMapping[_propertyId]
            .valueCurrentlyAvailable = propertyDetailsMapping[_propertyId]
            .valueAvailableForInvestment;

        investmentRecords[_propertyId][msg.sender] = true;

        investmentTimeRecord[_propertyId][msg.sender] = block.timestamp;

        investmentAmountRecords[_propertyId][msg.sender] = _amountToInvest;

        investorsDataMapping[msg.sender].propertyId.push(_propertyId);
        investorsDataMapping[msg.sender].amountInvested.push(_amountToInvest);
        uint256 len = investorsDataMapping[msg.sender].propertyId.length;
        investorsDataMapping[msg.sender].numberOfProperties = len;

        usdtMock.mintToken(
            msg.sender,
            propertyDetailsMapping[_propertyId].propertyOwnerAddress,
            _amountToInvest
        );

        propertyToken.approveToken(
            propertyDetailsMapping[_propertyId].propertyOwnerAddress,
            msg.sender,
            _amountToInvest
        );

        propertyToken.transferToken(
            propertyDetailsMapping[_propertyId].propertyOwnerAddress,
            msg.sender,
            _amountToInvest
        );

        emit InvestmentRecord(
            _propertyId,
            _amountToInvest,
            block.timestamp,
            investmentRecords[_propertyId][msg.sender]
        );
    }

    /// @dev function for allocating monthly rent to the investors.
    /// @param _propertyId the property id of the property
    /// @param _investorAddress the address of the investor whose monthly rent has to be calculated and transfered.
    /// @return uint256 the monthly rent that has to be transferred from the property owner to the investor
    function monthlyRent(
        uint256 _propertyId,
        address _investorAddress
    ) public returns (uint256) {
        require(
            msg.sender == _investorAddress ||
                msg.sender ==
                propertyDetailsMapping[_propertyId].propertyOwnerAddress,
            "Only the investor and the property owner can approve the monthly rent after 30 daya of the investment in the property"
        );
        require(
            listedProperties[_propertyId] == true,
            "Property not listed or has been de-listed"
        );

        require(
            block.timestamp >=
                investmentTimeRecord[_propertyId][_investorAddress] + timeFrame,
            "Rent can't be approved before 30 days"
        );

        uint256 monthlyIncomeFromInestment = (propertyDetailsMapping[
            _propertyId
        ].valueAvailableForInvestment *
            propertyDetailsMapping[_propertyId].annualEarning) /
            (propertyDetailsMapping[_propertyId].valueOfProperty * 12);

        uint256 _rentValue = (investmentAmountRecords[_propertyId][
            _investorAddress
        ] * monthlyIncomeFromInestment) /
            propertyDetailsMapping[_propertyId].valueAvailableForInvestment;

        if (msg.sender == _investorAddress) {
            propertyToken.approveToken(
                propertyDetailsMapping[_propertyId].propertyOwnerAddress,
                _investorAddress,
                _rentValue
            );
            propertyToken.transferToken(
                propertyDetailsMapping[_propertyId].propertyOwnerAddress,
                _investorAddress,
                _rentValue
            );
        } else {
            propertyToken.approveToken(
                propertyDetailsMapping[_propertyId].propertyOwnerAddress,
                _investorAddress,
                _rentValue
            );
            propertyToken.transferToken(
                propertyDetailsMapping[_propertyId].propertyOwnerAddress,
                _investorAddress,
                _rentValue
            );
        }
        return _rentValue;
    }

    /// @dev function for withdrawing all investments by the investor
    /// @param _propertyId the property id of the property from which the investment has to be withdrawn
    /// @param _investorAddress the address of the investor who is withdrawing the investment
    function withdrawInvestment(
        uint256 _propertyId,
        address _investorAddress
    ) public {
        require(
            listedProperties[_propertyId] == true,
            "Property not listed or has been de-listed"
        );
        require(
            investmentRecords[_propertyId][_investorAddress] == true,
            "Only the investor of the property can withdraw the funds"
        );
        uint256 _transferAmount = investmentAmountRecords[_propertyId][
            _investorAddress
        ];

        usdtMock.transferFunds(
            propertyDetailsMapping[_propertyId].propertyOwnerAddress,
            _investorAddress,
            _transferAmount
        );

        propertyToken.approveToken(
            _investorAddress,
            propertyDetailsMapping[_propertyId].propertyOwnerAddress,
            _transferAmount
        );
        propertyToken.transferToken(
            _investorAddress,
            propertyDetailsMapping[_propertyId].propertyOwnerAddress,
            _transferAmount
        );
    }

    /// @dev function for getting the state of properties, wether they are listed or not.
    /// @param _propertyId the property id of the property whose state has to be listed
    /// @return true if the property is listed
    function listedPropertyState(
        uint256 _propertyId
    ) public view returns (bool) {
        listedProperties[_propertyId] == false;
        return listedProperties[_propertyId];
    }

    /// @dev function for delisting the properties
    /// @param _propertyid property id of the property who has to be delisted
    function deListingProperty(uint256 _propertyid) public {
        require(
            listedProperties[_propertyid] == true,
            "Property has already been delisted or has never been listed"
        );
        require(
            msg.sender ==
                propertyDetailsMapping[_propertyid].propertyOwnerAddress,
            "Only owner can delist his/her property"
        );

        listedProperties[_propertyid] = false;
        propertyNFT.burnNFT(_propertyid);
    }

    /// @dev function for checking value of the property
    /// @param _propertyId property id of the property whose total value has to be fetched
    /// @return uint256 of value of property of property
    function checkValueOfProperty(
        uint256 _propertyId
    ) public view returns (uint256) {
        require(
            listedProperties[_propertyId] == true,
            "Property has not been listed"
        );
        return (propertyDetailsMapping[_propertyId].valueOfProperty);
    }

    /// @dev function for check the value of property available for investment.
    /// @param _propertyId property id of the property whose value available for investment is fetched
    /// @return uint256 of the value available for the investment
    function checkValueAvailableForInvestment(
        uint256 _propertyId
    ) public view returns (uint256) {
        require(
            listedProperties[_propertyId] == true,
            "Property has not been listed"
        );
        return (
            propertyDetailsMapping[_propertyId].valueAvailableForInvestment
        );
    }

    /// @dev function for checking the current available value of property for investment.
    /// @param _propertyId property id of the property whose value currently available for investment is fetched
    /// @return uint256 of the value currently available for the investment
    function checkvalueCurrentlyAvailable(
        uint256 _propertyId
    ) public view returns (uint256) {
        require(
            listedProperties[_propertyId] == true,
            "Property has not been listed"
        );
        return (propertyDetailsMapping[_propertyId].valueCurrentlyAvailable);
    }

    /// @dev function to check annual earning from the property.
    /// @param _propertyId property id of the property whose annual income has to be fetched
    /// @return uint256 of annual earning of the property owner from a particular property
    function checkannualEarning(
        uint256 _propertyId
    ) public view returns (uint256) {
        require(
            listedProperties[_propertyId] == true,
            "Property has not been listed"
        );
        return (propertyDetailsMapping[_propertyId].annualEarning);
    }

    /// @dev function for checking the balance.
    /// @param _user address of the account whose property token's balance has to be fetched
    /// @return uint256 of the balance of ERC20 property token
    function checkBalance(address _user) public view returns (uint256) {
        require(_user != address(0), "Invalid address");
        return propertyToken.balanceOf(_user);
    }

    /// @dev function for checking the USDT balance.
    /// @param _user address of the account whose USDT token balance has to be fetched
    /// @return uint256 of the balance of ERC20 mock USDT token
    function checkBalanceUsdt(address _user) public view returns (uint256) {
        require(_user != address(0), "Invalid address");
        return usdtMock.balanceOf(_user);
    }

    /// @dev function for fetch the investment record of any investor
    /// @param _investorData address of the investor whose data has to be fetched
    /// @return uint256 of array of property id of all the properties invested by the investor
    /// @return uint256 of array of amount invested in each property by the investor corresponding to their property id
    /// @return uint256 of the total number of properties in which the investor has invested
    function fetchInvestorData(
        address _investorData
    ) public view returns (uint256[] memory, uint256[] memory, uint256) {
        require(_investorData != address(0), "Invalid address");
        return (
            investorsDataMapping[_investorData].propertyId,
            investorsDataMapping[_investorData].amountInvested,
            investorsDataMapping[_investorData].numberOfProperties
        );
    }

    /// @dev function for fetch the property record of any owner
    /// @param _ownerAddress address of the owner whose data has to be fetched
    /// @return uint256 of array of property id of each of the property owned by the owner
    /// @return uint256 of array of NFT id of each of the property owned by the owner
    /// @return uint256 of total number of properties owned by the owner
    function fetchOwnerData(
        address _ownerAddress
    ) public view returns (uint256[] memory, uint256[] memory, uint256) {
        require(
            _ownerAddress == msg.sender,
            "Only owner can fetch the details of his/her property"
        );
        return (
            ownersDataMapping[_ownerAddress].propertyId,
            ownersDataMapping[_ownerAddress].NftId,
            ownersDataMapping[_ownerAddress].numberOfProperties
        );
    }

    /// @dev function to check the owner of the NFT
    /// @param _tokenId token id of the NFT whose owner has to be checked
    /// @return address of the owner of NFT
    function checkNFTOwner(uint256 _tokenId) public view returns (address) {
        return propertyNFT.checkOwner(_tokenId);
    }

    /// @dev function to check the owner property token name and symbol
    /// @param _tokenId token id of the property whose property token's name and symbol is to be fetched
    /// @return string of the name of the ERC20 property token for the provided property id
    /// @return string of the symbol of the ERC20 property token for the provided property id
    function checkPropertyTokenName(
        uint256 _tokenId
    ) public view returns (string memory, string memory) {
        require(listedProperties[_tokenId] == true, "Property is not listed");
        return (PropertyTokenName[_tokenId], PropertyTokenSymbol[_tokenId]);
    }
}
