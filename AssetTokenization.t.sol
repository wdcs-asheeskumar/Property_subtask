// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {AssetTokenization} from "../src/AssetTokenization.sol";
import {UsdtMock} from "../src/UsdtMock.sol";

contract AssetTokenizationTest is Test {
    AssetTokenization public assetTokenization;
    UsdtMock public usdtMock;

    function setUp() public {
        usdtMock = new UsdtMock();
        assetTokenization = new AssetTokenization(address(usdtMock));
    }

    /// @dev testcase to test the listing of property by the owner.
    function test_listProperty() public {
        vm.startPrank(0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf);
        setUp();
        bool temp = assetTokenization.listProperty(
            msg.sender,
            50000,
            20000,
            24000
        );

        assertEq(temp, true);
        vm.stopPrank();
    }

    /// @dev testcase to test the value of total property of the owner.
    function test_listPropertyTotalValue() public {
        vm.startPrank(0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf);
        setUp();
        assetTokenization.listProperty(msg.sender, 50000, 20000, 24000);
        uint256 temp = assetTokenization.checkValueOfProperty(1);
        assertEq(temp, 50000);
        vm.stopPrank();
    }

    /// @dev testcase to test the value of property alloted by the owner for investment at the initial stage.
    function test_listPropertyInvestmentValue() public {
        vm.startPrank(0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf);
        setUp();
        assetTokenization.listProperty(msg.sender, 50000, 20000, 24000);
        uint256 temp = assetTokenization.checkValueAvailableForInvestment(1);
        assertEq(temp, 20000);
        vm.stopPrank();
    }

    /// @dev testcase to test the value of property currently available for the investors to invest.
    function test_listPropertyCurrentlyAvailable() public {
        vm.startPrank(0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf);
        setUp();
        assetTokenization.listProperty(msg.sender, 50000, 20000, 24000);
        uint256 temp = assetTokenization.checkvalueCurrentlyAvailable(1);
        assertEq(temp, 20000);
        vm.stopPrank();
    }

    /// @dev testcase to test the annual income that is estimated by the owner.
    function test_listAnnualEarning() public {
        vm.startPrank(0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf);
        setUp();
        assetTokenization.listProperty(msg.sender, 50000, 20000, 24000);
        uint256 temp = assetTokenization.checkannualEarning(1);
        assertEq(temp, 24000);
        vm.stopPrank();
    }

    /// @dev testcse to test if the property is listed or not.
    function test_listedProperties() public {
        vm.startPrank(0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf);
        setUp();
        assetTokenization.listProperty(msg.sender, 50000, 20000, 24000);
        bool temp = assetTokenization.deListingProperty(1);
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

    function test_mintedTokens() public {
        vm.startPrank(0x04c1A796D9049ce70c2B4A188Ae441c4c619983c);
        setUp();
        uint256 temp = assetTokenization.mintedTokens(0x04c1A796D9049ce70c2B4A188Ae441c4c619983c, 10000);
        assertEq(temp, 10000);
        vm.stopPrank();
    }
    /// @dev testcase for checking the investment made by the investors.
    // function test_investInProperty() public {
    //     vm.startPrank(0x04c1A796D9049ce70c2B4A188Ae441c4c619983c);
    //     setUp();
    //     assetTokenization.listProperty(msg.sender, 50000, 20000, 24000);
    //     uint256 temp = assetTokenization.investInProperty(1, 0x04c1A796D9049ce70c2B4A188Ae441c4c619983c, 10);
    //     // uint256 temp = assetTokenization.toCheckUsdt(0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf);
    //     assertEq(temp, 10);
    //     vm.stopPrank();
    // }

    // /// @dev testcase for checking the balance od USDT tokens in the account of token holder
    // function test_toCheckUsdt() public {
    //     vm.startPrank(0xcF5D3555140A75E9b9a1ED56D1dB9E95064BA4D5);
    //     setUp();
    //     usdtMock.transfer(0x04c1A796D9049ce70c2B4A188Ae441c4c619983c, 2000);
    //     // address tempAdd = address(usdtMock);
    //     uint256 temp = assetTokenization.toCheckUsdt(0xcF5D3555140A75E9b9a1ED56D1dB9E95064BA4D5, 0x04c1A796D9049ce70c2B4A188Ae441c4c619983c);
    //     assertEq(temp, 2000);
    //     vm.stopPrank();
    // }

    /// @dev testcase to test the investments done by the investor.
    // function test_investInProperty() public {
    //     vm.startPrank(0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf);
    //     setUp();
    //     test_listProperty();

    //     vm.stopPrank();
    // }

    // function testFail_listProperty() public {
    //     vm.startPrank(address(0));
    //     setUp();
    //     bool temp = assetTokenization.listProperty(
    //         msg.sender,
    //         50000,
    //         20000,
    //         24000
    //     );

    //     assertEq(temp, false);
    //     vm.stopPrank();
    // }

    // function testFail_listProperty() public {
    //     vm.startPrank(0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf);
    //     setUp();
    //     assetTokenization.listProperty(msg.sender, 0, 20000, 24000);
    //     uint256 temp = assetTokentization.checkValueOfProperty(1);
    //     vm.stopPrank();
    // }

    // function test_Increment() public {
    //     counter.increment();
    //     assertEq(counter.number(), 1);
    // }

    // function testFuzz_SetNumber(uint256 x) public {
    //     counter.setNumber(x);
    //     assertEq(counter.number(), x);
    // }
}
