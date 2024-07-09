// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {AssetTokenization} from "../src/AssetTokenization.sol";
import {UsdtMock} from "../src/AssetTokenization.sol";
import {PropertyNFT} from "../src/AssetTokenization.sol";

contract AssetTokenizationTest is Test {
    AssetTokenization public assetTokenization;
    UsdtMock public usdtMock;
    PropertyNFT public propertyNFT;

    function setUp() public {
        usdtMock = new UsdtMock();
        propertyNFT = new PropertyNFT();
        assetTokenization = new AssetTokenization(
            address(usdtMock),
            address(propertyNFT)
        );
    }

    /// @dev testcase to test the listing of property by the owner.
    function test_listProperty() public {
        vm.startPrank(0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf);
        setUp();
        assetTokenization.listProperty(msg.sender, 50000, 20000, 24000);
        bool temp = assetTokenization.listedPropertyState(1);
        assertEq(temp, true);
        vm.stopPrank();
    }

    /// @dev testcase for checking the token balance of the owner once his property is listed.
    function test_checkBalance() public {
        vm.startPrank(0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf);
        setUp();
        assetTokenization.listProperty(msg.sender, 50000, 20000, 24000);
        uint256 temp = assetTokenization.checkBalance(msg.sender);
        assertEq(temp, 50000);
        vm.stopPrank();
    }

    /// @dev negative testcase to check Investors to invest in property.
    function test_investInProperty() public {
        vm.startPrank(0x04c1A796D9049ce70c2B4A188Ae441c4c619983c);
        setUp();
        assetTokenization.listProperty(
            0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf,
            50000,
            20000,
            24000
        );
        assetTokenization.investInProperty(
            1,
            0x04c1A796D9049ce70c2B4A188Ae441c4c619983c,
            100
        );
        uint256 tempInvestERC20 = assetTokenization.checkBalance(
            0x04c1A796D9049ce70c2B4A188Ae441c4c619983c
        );
        uint256 tempOwnerUSDTMock = assetTokenization.checkBalanceUsdt(
            0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf
        );
        uint256 tempOwnerERC20 = assetTokenization.checkBalance(
            0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf
        );
        assertEq(tempInvestERC20, 100);
        assertEq(tempOwnerUSDTMock, 100);
        assertEq(tempOwnerERC20, 49900);
        vm.stopPrank();
    }

    /// @dev testcase to check monthly rent functionality
    function test_monthlyRent() public {
        vm.startPrank(0x04c1A796D9049ce70c2B4A188Ae441c4c619983c);
        setUp();
        assetTokenization.listProperty(
            0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf,
            50000,
            20000,
            24000
        );
        assetTokenization.investInProperty(
            1,
            0x04c1A796D9049ce70c2B4A188Ae441c4c619983c,
            100
        );
        vm.warp(1725792566);
        assetTokenization.monthlyRent(
            1,
            0x04c1A796D9049ce70c2B4A188Ae441c4c619983c
        );
        uint256 temp = assetTokenization.checkBalance(
            0x04c1A796D9049ce70c2B4A188Ae441c4c619983c
        );
        assertEq(temp, 104);
        vm.stopPrank();
    }

    /// @dev testcase for total value of property of the owner
    function test_checkValueOfProperty() public {
        vm.startPrank(0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf);
        setUp();
        assetTokenization.listProperty(
            0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf,
            50000,
            20000,
            24000
        );
        uint256 temp = assetTokenization.checkValueOfProperty(1);
        assertEq(temp, 50000);
        vm.stopPrank();
    }

    /// @dev testcase to check the value of property available for investment
    function test_checkValueAvailableForInvestment() public {
        vm.startPrank(0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf);
        setUp();
        assetTokenization.listProperty(
            0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf,
            50000,
            20000,
            24000
        );
        uint256 temp = assetTokenization.checkValueAvailableForInvestment(1);
        assertEq(temp, 20000);
    }

    /// @dev testcase to check the value of property currently available for investment
    function test_checkvalueCurrentlyAvailable() public {
        vm.startPrank(0x04c1A796D9049ce70c2B4A188Ae441c4c619983c);
        setUp();
        assetTokenization.listProperty(
            0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf,
            50000,
            20000,
            24000
        );
        assetTokenization.investInProperty(
            1,
            0x04c1A796D9049ce70c2B4A188Ae441c4c619983c,
            100
        );
        uint256 temp = assetTokenization.checkvalueCurrentlyAvailable(1);
        assertEq(temp, 19900);
        vm.stopPrank();
    }

    /// @dev testcase for checking the annual earning from the property by the owner
    function test_checkannualEarning() public {
        vm.startPrank(0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf);
        setUp();
        assetTokenization.listProperty(
            0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf,
            50000,
            20000,
            24000
        );
        uint256 temp = assetTokenization.checkannualEarning(1);
        assertEq(temp, 24000);
        vm.stopPrank();
    }

    /// @dev testcase for checking functionality of checking the balance of the erc20 tokens
    function test_checkBalanceUSDT() public {
        vm.startPrank(0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf);
        setUp();
        assetTokenization.listProperty(
            0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf,
            50000,
            20000,
            24000
        );
        uint256 temp = assetTokenization.checkBalanceUsdt(
            0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf
        );
        assertEq(temp, 0);
        vm.stopPrank();

        vm.startPrank(0x04c1A796D9049ce70c2B4A188Ae441c4c619983c);
        setUp();
        assetTokenization.listProperty(
            0x04c1A796D9049ce70c2B4A188Ae441c4c619983c,
            50000,
            20000,
            24000
        );
        assetTokenization.investInProperty(
            1,
            0x04c1A796D9049ce70c2B4A188Ae441c4c619983c,
            100
        );
        uint256 temp2 = assetTokenization.checkBalanceUsdt(
            0x04c1A796D9049ce70c2B4A188Ae441c4c619983c
        );
        assertEq(temp2, 100);
        vm.stopPrank();
    }

    // /// @dev testcase to check the properties that are delisted
    function test_deListingProperty() public {
        vm.startPrank(0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf);
        setUp();
        assetTokenization.listProperty(
            0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf,
            50000,
            20000,
            24000
        );
        assetTokenization.deListingProperty(1);
        bool temp = assetTokenization.listedPropertyState(1);
        assertEq(temp, false);
        vm.stopPrank();
    }

    /// @dev testcase to withdraw the investment
    function test_withdrawInvestment() public {
        vm.startPrank(0x04c1A796D9049ce70c2B4A188Ae441c4c619983c);
        setUp();
        assetTokenization.listProperty(
            0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf,
            50000,
            20000,
            24000
        );
        assetTokenization.investInProperty(
            1,
            0x04c1A796D9049ce70c2B4A188Ae441c4c619983c,
            100
        );
        assetTokenization.withdrawInvestment(
            1,
            0x04c1A796D9049ce70c2B4A188Ae441c4c619983c
        );
        uint256 temp = assetTokenization.checkBalanceUsdt(
            0x04c1A796D9049ce70c2B4A188Ae441c4c619983c
        );
        assertEq(temp, 100);
        vm.stopPrank();
    }

    // <=========================================Negative Testcases=========================================>

    /// @dev negative testcase to test the listing of property by the owner.
    function testFail_listProperty() public {
        vm.startPrank(0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf);
        setUp();
        assetTokenization.listProperty(address(0), 50000, 20000, 24000);

        bool temp = assetTokenization.listedPropertyState(1);
        assertEq(temp, false);
    }

    /// @dev negative testcase to check the checkBalance functionality
    function testFail_checkBalance() public {
        vm.startPrank(address(0));
        setUp();
        assetTokenization.listProperty(
            0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf,
            50000,
            20000,
            24000
        );
        uint256 temp = assetTokenization.checkBalance(address(0));
        assertEq(temp, 50000);
        vm.stopPrank();
    }

    /// @dev negative testcase to check Investors to invest in property.
    function testFail_investInProperty() public {
        vm.startPrank(0x04c1A796D9049ce70c2B4A188Ae441c4c619983c);
        setUp();
        assetTokenization.listProperty(
            0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf,
            50000,
            20000,
            24000
        );
        assetTokenization.investInProperty(
            2,
            0x04c1A796D9049ce70c2B4A188Ae441c4c619983c,
            100
        );
        bool tempListed = assetTokenization.listedPropertyState(2);
        assertEq(tempListed, true);

        uint256 tempInvestERC20 = assetTokenization.checkBalance(
            0x04c1A796D9049ce70c2B4A188Ae441c4c619983c
        );
        uint256 tempOwnerUSDTMock = assetTokenization.checkBalanceUsdt(
            0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf
        );
        uint256 tempOwnerERC20 = assetTokenization.checkBalance(
            0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf
        );
        assertEq(tempInvestERC20, 100);
        assertEq(tempOwnerUSDTMock, 100);
        assertEq(tempOwnerERC20, 49900);
        vm.stopPrank();
    }

    /// @dev negative testcase to check Investors to invest in property.
    function testFail_investInProperty2() public {
        vm.startPrank(0x04c1A796D9049ce70c2B4A188Ae441c4c619983c);
        setUp();
        assetTokenization.listProperty(
            0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf,
            50000,
            20000,
            24000
        );
        assetTokenization.investInProperty(
            1,
            0x04c1A796D9049ce70c2B4A188Ae441c4c619983c,
            1000000
        );

        uint256 tempInvestERC20 = assetTokenization.checkBalance(
            0x04c1A796D9049ce70c2B4A188Ae441c4c619983c
        );
        uint256 tempOwnerUSDTMock = assetTokenization.checkBalanceUsdt(
            0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf
        );
        uint256 tempOwnerERC20 = assetTokenization.checkBalance(
            0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf
        );
        assertEq(tempInvestERC20, 100);
        assertEq(tempOwnerUSDTMock, 100);
        assertEq(tempOwnerERC20, 49900);
        vm.stopPrank();
    }

    /// @dev negative testcase to check monthly rent functionality
    function testFail_monthlyRent() public {
        vm.startPrank(0x04c1A796D9049ce70c2B4A188Ae441c4c619983c);
        setUp();
        assetTokenization.listProperty(
            0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf,
            50000,
            20000,
            24000
        );
        assetTokenization.investInProperty(
            1,
            0x04c1A796D9049ce70c2B4A188Ae441c4c619983c,
            100
        );
        // vm.warp(1725792566);
        assetTokenization.monthlyRent(
            1,
            0x04c1A796D9049ce70c2B4A188Ae441c4c619983c
        );
        uint256 temp = assetTokenization.checkBalance(
            0x04c1A796D9049ce70c2B4A188Ae441c4c619983c
        );
        assertEq(temp, 104);
        vm.stopPrank();
    }

    /// @dev negative testcase to check monthly rent functionality
    function testFail_monthlyRent2() public {
        vm.startPrank(0x04c1A796D9049ce70c2B4A188Ae441c4c619983c);
        setUp();
        assetTokenization.listProperty(
            0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf,
            50000,
            20000,
            24000
        );
        assetTokenization.investInProperty(
            1,
            0x04c1A796D9049ce70c2B4A188Ae441c4c619983c,
            100
        );
        vm.warp(1725792566);
        assetTokenization.monthlyRent(
            1,
            0x04c1A796D9049ce70c2B4A188Ae441c4c619983c
        );
        uint256 temp = assetTokenization.checkBalance(
            0x04c1A796D9049ce70c2B4A188Ae441c4c619983c
        );
        assertEq(temp, 100);
        vm.stopPrank();
    }

    /// @dev negative testcase for total value of property of the owner
    function testFail_checkValueOfProperty() public {
        vm.startPrank(0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf);
        setUp();
        assetTokenization.listProperty(
            0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf,
            50000,
            20000,
            24000
        );
        uint256 temp = assetTokenization.checkValueOfProperty(10);
        assertEq(temp, 50000);
        vm.stopPrank();
    }

    /// @dev negative testcase to check the value of property available for investment
    function testFail_checkValueAvailableForInvestment() public {
        vm.startPrank(0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf);
        setUp();
        assetTokenization.listProperty(
            0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf,
            50000,
            20000,
            24000
        );
        uint256 temp = assetTokenization.checkValueAvailableForInvestment(10);
        assertEq(temp, 20000);
    }

    /// @dev negative testcase to check the value of property currently available for investment
    function testFail_checkvalueCurrentlyAvailable() public {
        vm.startPrank(0x04c1A796D9049ce70c2B4A188Ae441c4c619983c);
        setUp();
        assetTokenization.listProperty(
            0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf,
            50000,
            20000,
            24000
        );
        assetTokenization.investInProperty(
            1,
            0x04c1A796D9049ce70c2B4A188Ae441c4c619983c,
            100
        );
        uint256 temp = assetTokenization.checkvalueCurrentlyAvailable(10);
        assertEq(temp, 19900);
        vm.stopPrank();
    }

    /// @dev negative testcase for checking the annual earning from the property by the owner
    function testFail_checkannualEarning() public {
        vm.startPrank(0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf);
        setUp();
        assetTokenization.listProperty(
            0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf,
            50000,
            20000,
            24000
        );
        uint256 temp = assetTokenization.checkannualEarning(10);
        assertEq(temp, 24000);
        vm.stopPrank();
    }

    /// @dev negative testcase for checking functionality of checking the balance of the erc20 tokens
    function testFail_checkBalanceUSDT() public {
        vm.startPrank(0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf);
        setUp();
        assetTokenization.listProperty(address(0), 50000, 20000, 24000);
        uint256 temp = assetTokenization.checkBalanceUsdt(
            0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf
        );
        assertEq(temp, 0);
        vm.stopPrank();
    }

    /// @dev negative testcase for checking functionality of checking the balance of the erc20 tokens
    function testFail_checkBalanceUSDT2() public {
        vm.startPrank(0x04c1A796D9049ce70c2B4A188Ae441c4c619983c);
        setUp();
        assetTokenization.listProperty(
            0x04c1A796D9049ce70c2B4A188Ae441c4c619983c,
            50000,
            20000,
            24000
        );
        assetTokenization.investInProperty(
            1,
            0x04c1A796D9049ce70c2B4A188Ae441c4c619983c,
            100
        );
        uint256 temp = assetTokenization.checkBalanceUsdt(address(0));
        assertEq(temp, 100);
        vm.stopPrank();
    }

    /// @dev negative testcase to withdraw the investment
    function testFail_withdrawInvestment2() public {
        vm.startPrank(0x04c1A796D9049ce70c2B4A188Ae441c4c619983c);
        setUp();
        assetTokenization.listProperty(
            0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf,
            50000,
            20000,
            24000
        );
        assetTokenization.investInProperty(
            1,
            0x04c1A796D9049ce70c2B4A188Ae441c4c619983c,
            100
        );
        assetTokenization.withdrawInvestment(
            2,
            0x04c1A796D9049ce70c2B4A188Ae441c4c619983c
        );
        uint256 temp = assetTokenization.checkBalanceUsdt(
            0x04c1A796D9049ce70c2B4A188Ae441c4c619983c
        );
        assertEq(temp, 100);
        vm.stopPrank();
    }
    /// @dev negative testcase to check the properties that are delisted
    function testFail_deListingProperty() public {
        vm.startPrank(0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf);
        setUp();
        assetTokenization.listProperty(
            0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf,
            50000,
            20000,
            24000
        );
        assetTokenization.deListingProperty(2);
        bool temp = assetTokenization.listedPropertyState(2);
        assertEq(temp, false);
        vm.stopPrank();
    }
}
