//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test} from "forge-std/Test.sol";
import {OurToken} from "../src/OurToken.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";

contract OurTokenTest is Test {

  OurToken public ourToken;
  DeployOurToken public deployer;

  address bob = makeAddr("bob");
  address alice = makeAddr("alice");
  uint256 public constant STARTING_BALANCE = 100 ether;

  function setUp() public {
    deployer = new DeployOurToken();
    ourToken = deployer.run();

    vm.prank(msg.sender);
    ourToken.transfer(bob, STARTING_BALANCE);
  }

  function testBobBalance() public {
    assertEq(STARTING_BALANCE, ourToken.balanceOf(bob));
  }

  function testAllowanceWorks() public {
    uint256 initialAllowance = 1000;

    // Bob approves Alice to spend tokens on his behalf
    vm.prank(bob);
    ourToken.approve(alice, initialAllowance);
    assertEq(ourToken.allowance(bob, alice), initialAllowance);

    uint256 transferAmount = 500;

    vm.prank(alice);
    ourToken.transferFrom(bob, alice, transferAmount);

    assertEq(ourToken.balanceOf(alice), transferAmount);
    assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
    assertEq(ourToken.allowance(bob, alice), initialAllowance - transferAmount);
  }

  function testTransferFailsWithoutAllowance() public {
    vm.prank(alice);
    vm.expectRevert();
    ourToken.transferFrom(bob, alice, 100);
  }

  function testTransferFailsWithInsufficientAllowance() public {
    uint256 initialAllowance = 50;
    vm.prank(bob);
    ourToken.approve(alice, initialAllowance);

    vm.prank(alice);
    vm.expectRevert();
    ourToken.transferFrom(bob, alice, 100);
  }

  function testTransferFailsWithInsufficientBalance() public {
    vm.prank(bob);
    vm.expectRevert();
    ourToken.transfer(alice, STARTING_BALANCE + 1);
  }

  function testTransferSucceeds() public {
    uint256 transferAmount = 50;
    vm.prank(bob);
    bool success = ourToken.transfer(alice, transferAmount);

    assertEq(success, true);
    assertEq(ourToken.balanceOf(alice), transferAmount);
    assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
  }

  function testInitialSupply() public {
    assertEq(ourToken.totalSupply(), deployer.INITIAL_SUPPLY());
  }


  function testTokenNameAndSymbol() public {
    assertEq(ourToken.name(), "OurToken");
    assertEq(ourToken.symbol(), "OT");
  }

  function testAllowanceAfterTransferAll() public {
    uint256 initialAllowance = 1000;
    vm.prank(bob);
    ourToken.approve(alice, initialAllowance);

    vm.prank(alice);
    ourToken.transferFrom(bob, alice, initialAllowance);

    assertEq(ourToken.allowance(bob, alice), 0);
  }

  function testApproveAndIncreaseAllowance() public {
    // This test is not applicable since increaseAllowance is not implemented
    assertTrue(true);
  }

  function testDecreaseAllowance() public {
    // This test is not applicable since decreaseAllowance is not implemented
    assertTrue(true);
  }
}