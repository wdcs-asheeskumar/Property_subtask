// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// import "/home/webclues/Desktop/MyProjects/Subtask/subtask/src/UsdtMock.sol";

/// @dev MockUsdt contract

contract UsdtMock is ERC20 {
    constructor() ERC20("MockUsdt", "USDT") {
        // _mint(msg.sender, 10000000000 * (10 ** decimals()));
    }

    function mintToken(address to, uint256 value) public {
        _mint(to, value);
    }
    function giveApproval(address _address, uint256 value) public {
        approve(_address, value);
    }

    function checkApproval(
        address owner,
        address spender
    ) public view returns (uint256) {
        return (allowance(owner, spender));
    }

    function transferFunds(address to, uint256 value) public {
        transfer(to, value);
    }

    function checkBalance(address owner) public view returns (uint256) {
        return balanceOf(owner);
    }
}

contract AssetTokenization is ERC20 {
    struct PropertyOwnerDetails {
        uint256 propertyId;
        address propertyOwnerAddress;
        uint256 valueOfProperty;
        uint256 valueAvailableForInvestment;
        uint256 annualEarning;
        uint256 monthlyEarningFromInvestment;
        uint256 valueInvested;
        uint256 valueCurrentlyAvailable;
        uint256 noOfInvestors;
    }

    /// @dev keeping tract of all the property and there details.
    mapping(uint256 => PropertyOwnerDetails) propertyDetailsMapping;

    /// @dev keeping the list of owners of the property
    mapping(address => uint256) ownerPropertyList;

    /// @dev keeping the record of listed properties
    mapping(uint256 => bool) listedProperties;
    /// @dev keeps record of the investor has invested in certain property or not.
    mapping(uint256 => mapping(address => bool)) investmentRecords;

    /// @dev keeps record of the amount of investment done by the investor in a particular property.
    mapping(uint256 => mapping(address => uint256)) investmentAmountRecords;

    /// @dev keeps record of the time at which the investor has invested on a property
    mapping(uint256 => mapping(address => uint256)) investmentTimeRecord;

    /// @dev time period at which the rent will be paid to the investor
    uint256 private timeFrame = 30 days;
    uint256 public id = 0;

    event ListPropertyInfo(
        uint256 _id,
        address _ownerAddress,
        uint256 _valueOfProperty,
        uint256 _valueAvailableForInvestment,
        uint256 _annualEarning
    );

    event InvestmentRecord(
        uint256 _propertyId,
        uint256 _amountToInvest,
        uint256 _investmentTimeRecord,
        bool _investmentStatus
    );

    // ERC20 private USDT_Address =
    //     ERC20(0x04c1A796D9049ce70c2B4A188Ae441c4c619983c);
    address InvestorsUSDTToken;

    UsdtMock public usdtMock;

    // UsdtMock public usdtMock;
    constructor(address _usdtMock) ERC20("MyPropertyToken", "MPK") {
        usdtMock = UsdtMock(_usdtMock);
    }

    /// @dev function for the owner to list his property.
    function listProperty(
        address _ownerAddress,
        uint256 _valueOfProperty,
        uint256 _valueAvailableForInvestment,
        uint256 _annualEarning
    ) public returns (bool) {
        require(_ownerAddress != address(0), "Invalid address");
        require(_valueOfProperty > 0, "Invalid value of property");
        require(
            _valueAvailableForInvestment < _valueOfProperty &&
                _valueAvailableForInvestment > 0,
            "Invalid value available for investment"
        );
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
        _mint(_ownerAddress, _valueOfProperty);

        emit ListPropertyInfo(
            id,
            _ownerAddress,
            _valueOfProperty,
            _valueAvailableForInvestment,
            _annualEarning
        );

        return listedProperties[id];
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

        propertyDetailsMapping[_propertyId].noOfInvestors =
            propertyDetailsMapping[_propertyId].noOfInvestors +
            1;

        propertyDetailsMapping[_propertyId].valueInvested =
            propertyDetailsMapping[_propertyId].valueInvested +
            _amountToInvest;

        propertyDetailsMapping[_propertyId].valueCurrentlyAvailable =
            propertyDetailsMapping[_propertyId].valueAvailableForInvestment -
            _amountToInvest;

        investmentRecords[_propertyId][_investorsAddress] = true;

        investmentTimeRecord[_propertyId][_investorsAddress] = block.timestamp;

        investmentAmountRecords[_propertyId][
            _investorsAddress
        ] = _amountToInvest;

        // ERC20(usdtMock).mint(
        //     msg.sender,
        //     propertyDetailsMapping[_propertyId].propertyOwnerAddress,
        //     _amountToInvest
        // );

        usdtMock.mintToken(_investorsAddress, _amountToInvest);
        ERC20(usdtMock).transferFrom(
            _investorsAddress,
            propertyDetailsMapping[_propertyId].propertyOwnerAddress,
            _amountToInvest
        );

        transferFrom(
            propertyDetailsMapping[_propertyId].propertyOwnerAddress,
            _investorsAddress,
            _amountToInvest
        );
        emit InvestmentRecord(
            _propertyId,
            _amountToInvest,
            block.timestamp,
            investmentRecords[_propertyId][_investorsAddress]
        );
        // return toCheckUsdt(_investorsAddress);
    }

    /// @dev function for allocating monthly rent to the investors.
    function monthlyRent(uint256 _propertyId, address _investorAddress) public {
        require(
            listedProperties[_propertyId] == true,
            "Property not listed or has been de-listed"
        );

        require(
            investmentTimeRecord[_propertyId][_investorAddress] + timeFrame >=
                block.timestamp,
            "Rent can't be approved before 30 days"
        );
        uint256 _investment = investmentAmountRecords[_propertyId][
            _investorAddress
        ];
        uint256 _rentValue = (_investment *
            propertyDetailsMapping[_propertyId].monthlyEarningFromInvestment) /
            propertyDetailsMapping[_propertyId].valueAvailableForInvestment;
        transfer(_investorAddress, _rentValue);
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
        uint256 _transaferAmount = investmentAmountRecords[_propertyId][
            _investorAddress
        ];
        transferFrom(
            propertyDetailsMapping[_propertyId].propertyOwnerAddress,
            _investorAddress,
            _transaferAmount
        );
    }

    function deListingProperty(uint256 _propertyId) public view returns (bool) {
        require(
            listedProperties[_propertyId] == true,
            "Property has already been delisted"
        );
        listedProperties[_propertyId] == false;
        return listedProperties[_propertyId];
    }

    function checkValueOfProperty(
        uint256 _propertyId
    ) public view returns (uint256) {
        require(
            listedProperties[_propertyId] == true,
            "Property has not been listed"
        );
        return (propertyDetailsMapping[_propertyId].valueOfProperty);
    }

    function checkValueAvailableForInvestment(
        uint256 _propertyId
    ) public view returns (uint256) {
        return (
            propertyDetailsMapping[_propertyId].valueAvailableForInvestment
        );
    }

    function checkvalueCurrentlyAvailable(
        uint256 _propertyId
    ) public view returns (uint256) {
        return (propertyDetailsMapping[_propertyId].valueCurrentlyAvailable);
    }

    function checkannualEarning(
        uint256 _propertyId
    ) public view returns (uint256) {
        return (propertyDetailsMapping[_propertyId].annualEarning);
    }

    function checkBalance(address _ownerAddress) public view returns (uint256) {
        return balanceOf(_ownerAddress);
    }

    function toCheckUsdt(address to, uint256 value) public returns (uint256) {
        // ERC20(InvestorsUSDTToken).transferFrom(spender, 0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf, 10);
        // return ERC20(InvestorsUSDTToken).balanceOf(spender);
        // return ERC20(InvestorsUSDTToken).balanceOf(owner);

        ERC20(usdtMock).mintToken(to, value);
        return usdtMock.checkBalance(to);
    }
}
