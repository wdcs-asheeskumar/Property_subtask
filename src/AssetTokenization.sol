// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/// @dev MockUsdt contract
contract UsdtMock is ERC20 {
    constructor() ERC20("MockUsdt", "USDT") {
        // _mint(msg.sender, 10000000000 * (10 ** decimals()));
    }

    /// @dev function to mint token and transfer it from investor to owner
    function mintToken(address investor, address owner, uint256 value) public {
        _mint(investor, value);
        _transfer(investor, owner, value);
    }
    // function giveApproval(address _address, uint256 value) public {
    //     approve(_address, value);
    // }

    function checkApproval(
        address owner,
        address spender
    ) public view returns (uint256) {
        return (allowance(owner, spender));
    }

    /// @dev function to transfer funds from investor to owner as well as from owner to investor
    function transferFunds(
        address investor,
        address owner,
        uint256 value
    ) public {
        _transfer(investor, owner, value);
    }

    /// @dev function to check the USDT balance of the user.
    function checkBalance(address owner) public view returns (uint256) {
        return balanceOf(owner);
    }
}

/// @dev NFT contract to mint NFT in the owner's account when he lists his property
contract PropertyNFT is ERC721 {
    constructor() ERC721("PropertyNFT", "PNFT") {}

    function safeMint(address to, uint256 tokenId) public {
        _safeMint(to, tokenId);
    }

    function checkOwner(uint256 _tokenId) public view returns (address) {
        return _ownerOf(_tokenId);
    }

    function burnNFT(uint256 _tokenId) public {
        _burn(_tokenId);
    }
}

/// @dev Asset tokenization contract
contract AssetTokenization is ERC20 {
    /// @dev struct to store the data of property.
    struct PropertyOwnerDetails {
        uint256 propertyId; // 1
        address propertyOwnerAddress;
        uint256 valueOfProperty; // 50000
        uint256 valueAvailableForInvestment; // 20000
        uint256 annualEarning; // 24000
        uint256 monthlyEarningFromInvestment;
        uint256 valueInvested; /// @dev Amount of total investment done by all investors till now.
        uint256 valueCurrentlyAvailable; /// @dev Amount of value of property currently remaining.
        uint256 noOfInvestors;
    }

    /// @dev struct to store the data and investment record of the investor
    struct InvestorsData {
        uint256[] propertyId;
        uint256[] amountInvested;
        uint256 numberOfProperties;
    }

    /// @dev struct to store the data and properties record of the owner
    struct OwnersData {
        uint256[] propertyId;
        uint256[] NftId;
        uint256[] valueInvested;
        uint256[] valueCurrentlyAvailable;
        uint256 numberOfProperties;
    }

    /// @dev mapping for keeping tract of all the property and there details.
    mapping(uint256 => PropertyOwnerDetails) public propertyDetailsMapping;

    /// @dev mapping for keeping the list of number of owners of the property
    mapping(address => uint256) public ownerPropertyList;

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

    // ERC20 private USDT_Address =
    //     ERC20(0x04c1A796D9049ce70c2B4A188Ae441c4c619983c);

    UsdtMock public usdtMock;

    PropertyNFT public propertyNFT;

    constructor(
        address _usdtMock,
        address _propertyNFT
    ) ERC20("MyPropertyToken", "MPK") {
        usdtMock = UsdtMock(_usdtMock);
        propertyNFT = PropertyNFT(_propertyNFT);
    }

    /// @dev function for the owner to list his property.
    function listProperty(
        address _ownerAddress,
        uint256 _valueOfProperty,
        uint256 _valueAvailableForInvestment,
        uint256 _annualEarning
    ) public {
        require(_ownerAddress != address(0), "Invalid address");
        require(_valueOfProperty > 0, "Invalid value of property");
        require(
            _valueAvailableForInvestment <= _valueOfProperty &&
                _valueAvailableForInvestment > 0,
            "Invalid value available for investment"
        );
        require(listedProperties[id] == false, "Property allready listed");

        id = id + 1;

        uint256 monthlyIncomeFromInestment = (_valueAvailableForInvestment *
            _annualEarning) / (_valueOfProperty * 12);

        propertyDetailsMapping[id].propertyId = id;
        propertyDetailsMapping[id].propertyOwnerAddress = _ownerAddress;
        propertyDetailsMapping[id].valueOfProperty = _valueOfProperty;
        propertyDetailsMapping[id]
            .valueAvailableForInvestment = _valueAvailableForInvestment;
        propertyDetailsMapping[id]
            .valueCurrentlyAvailable = _valueAvailableForInvestment;
        propertyDetailsMapping[id].annualEarning = _annualEarning;
        propertyDetailsMapping[id]
            .monthlyEarningFromInvestment = monthlyIncomeFromInestment;
        ownerPropertyList[_ownerAddress] = ownerPropertyList[_ownerAddress] + 1;

        listedProperties[id] = true;
        _mint(_ownerAddress, _valueOfProperty); /// @dev minting tokens equivalent to the value of property in owner's account.
        propertyNFT.safeMint(_ownerAddress, id); /// @dev minting NFT token in the user's account.

        /// @dev storing data only for owner
        ownersDataMapping[_ownerAddress].propertyId.push(id); /// @dev storing the id of the property
        ownersDataMapping[_ownerAddress].NftId.push(id); /// @dev storing the id of the NFT
        ownersDataMapping[_ownerAddress].valueInvested.push(0); /// @dev storing the value that has been invested
        ownersDataMapping[_ownerAddress].valueCurrentlyAvailable.push(
            _valueAvailableForInvestment
        ); /// @dev storing the value currently available for investment
        uint256 temp = ownersDataMapping[_ownerAddress].propertyId.length;
        ownersDataMapping[_ownerAddress].numberOfProperties = temp; /// @dev storing the total number of properties

        /// @dev emiting the event ListProppertyInfo for emitting the information about the property.
        emit ListPropertyInfo(
            id,
            _ownerAddress,
            _valueOfProperty,
            _valueAvailableForInvestment,
            _annualEarning
        );

        // return listedProperties[id];
    }

    /// @dev function to check the current status of the property.
    function checkingProperty(
        uint256 _idNumber
    )
        public
        view
        returns (address, uint256, uint256, uint256, uint256, uint256)
    {
        require(
            listedProperties[_idNumber] == true,
            "Property not listed or has been de-listed"
        );
        return (
            propertyDetailsMapping[_idNumber].propertyOwnerAddress,
            propertyDetailsMapping[_idNumber].valueOfProperty,
            propertyDetailsMapping[_idNumber].valueAvailableForInvestment,
            propertyDetailsMapping[_idNumber].valueCurrentlyAvailable,
            propertyDetailsMapping[_idNumber].annualEarning,
            propertyDetailsMapping[_idNumber].monthlyEarningFromInvestment
        );
    }

    /// @dev function for the investor to invest in the property
    function investInProperty(
        uint256 _propertyId,
        address _investorsAddress,
        uint256 _amountToInvest
    ) public {
        require(
            listedProperties[_propertyId] == true,
            "Property not listed or has been de-listed"
        );
        require(
            investmentRecords[_propertyId][_investorsAddress] == false,
            "Investor has already invested in this property"
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
        uint256 valInv = propertyDetailsMapping[_propertyId].valueInvested +
            _amountToInvest;

        uint256 valCurrentlyAvailable = propertyDetailsMapping[_propertyId]
            .valueAvailableForInvestment - _amountToInvest;

        propertyDetailsMapping[_propertyId].noOfInvestors =
            propertyDetailsMapping[_propertyId].noOfInvestors +
            1;

        propertyDetailsMapping[_propertyId].valueInvested = valInv;

        propertyDetailsMapping[_propertyId]
            .valueCurrentlyAvailable = valCurrentlyAvailable;

        investmentRecords[_propertyId][_investorsAddress] = true;

        investmentTimeRecord[_propertyId][_investorsAddress] = block.timestamp;

        investmentAmountRecords[_propertyId][
            _investorsAddress
        ] = _amountToInvest;

        investorsDataMapping[_investorsAddress].propertyId.push(_propertyId);
        investorsDataMapping[_investorsAddress].amountInvested.push(
            _amountToInvest
        );
        uint256 len = investorsDataMapping[_investorsAddress].propertyId.length;
        investorsDataMapping[_investorsAddress].numberOfProperties = len;

        ownersDataMapping[
            propertyDetailsMapping[_propertyId].propertyOwnerAddress
        ].valueInvested[_propertyId - 1] = valInv; /// @dev storing the value that has been invested

        ownersDataMapping[
            propertyDetailsMapping[_propertyId].propertyOwnerAddress
        ].valueCurrentlyAvailable[_propertyId - 1] = propertyDetailsMapping[
            _propertyId
        ].valueCurrentlyAvailable;

        usdtMock.mintToken(
            _investorsAddress,
            propertyDetailsMapping[_propertyId].propertyOwnerAddress,
            _amountToInvest
        );

        _approve(
            propertyDetailsMapping[_propertyId].propertyOwnerAddress,
            _investorsAddress,
            _amountToInvest
        );
        transferFrom(
            propertyDetailsMapping[_propertyId].propertyOwnerAddress,
            _investorsAddress,
            _amountToInvest
        );

        /// @dev emiting the InvestmentRecord event to give the information about the Investment.
        emit InvestmentRecord(
            _propertyId,
            _amountToInvest,
            block.timestamp,
            investmentRecords[_propertyId][_investorsAddress]
        );

        // return balanceOf(_investorsAddress);
    }

    /// @dev function for allocating monthly rent to the investors.
    function monthlyRent(
        uint256 _propertyId,
        address _investorAddress
    ) public returns (uint256) {
        require(
            listedProperties[_propertyId] == true,
            "Property not listed or has been de-listed"
        );

        require(
            block.timestamp >=
                investmentTimeRecord[_propertyId][_investorAddress] + timeFrame,
            "Rent can't be approved before 30 days"
        );

        /// @dev fetching the total investment done by the investor in that particular property.
        uint256 _investment = investmentAmountRecords[_propertyId][
            _investorAddress
        ];

        /// @dev calculating the monthly rent to be rewarded to the investor in that particular property.
        uint256 monthlyEarning = propertyDetailsMapping[_propertyId]
            .monthlyEarningFromInvestment;
        uint256 valAvailableForInvestment = propertyDetailsMapping[_propertyId]
            .valueAvailableForInvestment;

        uint256 _rentValue = (_investment * monthlyEarning) /
            valAvailableForInvestment;
        // uint256 _rentValue = 100;
        // _approve(owner, spender, value);
        _approve(
            propertyDetailsMapping[_propertyId].propertyOwnerAddress,
            _investorAddress,
            _rentValue
        );
        transferFrom(
            propertyDetailsMapping[_propertyId].propertyOwnerAddress,
            _investorAddress,
            _rentValue
        );
        return _rentValue;
    }

    /// @dev function for withdrawing all investments by the investor
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
            "Only the owner of the property can withdraw the funds"
        );
        uint256 _transferAmount = investmentAmountRecords[_propertyId][
            _investorAddress
        ];

        /// @dev returning the USDT token from the owner's account to the investor.
        usdtMock.transferFunds(
            propertyDetailsMapping[_propertyId].propertyOwnerAddress,
            _investorAddress,
            _transferAmount
        );
    }

    /// @dev function for getting the state of properties, wether they are listed or not.
    function listedPropertyState(
        uint256 _propertyId
    ) public view returns (bool) {
        // require(
        //     listedProperties[_propertyId] == true,
        //     "Property has already been delisted or has never been listed"
        // );
        listedProperties[_propertyId] == false;
        return listedProperties[_propertyId];
    }

    /// @dev function for delisting the properties
    function deListingProperty(uint256 _id) public {
        require(
            listedProperties[_id] == true,
            "Property has already been delisted or has never been listed"
        );
        require(
            msg.sender == propertyDetailsMapping[_id].propertyOwnerAddress,
            "Only owner can delist his/her property"
        );

        listedProperties[_id] = false;
        propertyNFT.burnNFT(_id);
    }

    /// @dev function for checking value of the property
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
    function checkBalance(address _user) public view returns (uint256) {
        require(_user != address(0), "Invalid address");
        return balanceOf(_user);
    }

    /// @dev function for checking the USDT balance.
    function checkBalanceUsdt(address _user) public view returns (uint256) {
        require(_user != address(0), "Invalid address");
        // usdtMock.mintToken(_investor, _owner, 1000);
        return usdtMock.balanceOf(_user);
    }

    /// @dev function for fetch the investment record of any investor
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
    function fetchOwnerData(
        address _ownerAddress
    )
        public
        view
        returns (
            uint256[] memory,
            uint256[] memory,
            uint256[] memory,
            uint256[] memory,
            uint256
        )
    {
        require(
            _ownerAddress == msg.sender,
            "Only owner can fetch the details of his/her property"
        );
        return (
            ownersDataMapping[_ownerAddress].propertyId,
            ownersDataMapping[_ownerAddress].NftId,
            ownersDataMapping[_ownerAddress].valueInvested,
            ownersDataMapping[_ownerAddress].valueCurrentlyAvailable,
            ownersDataMapping[_ownerAddress].numberOfProperties
        );
    }
    /// @dev function to check the owner of the NFT
    function checkNFTOwner(uint256 _tokenId) public view returns (address) {
        return propertyNFT.checkOwner(_tokenId);
    }
}
