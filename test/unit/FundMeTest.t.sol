// SPDX-License-Identifier: MIT

// 1. Pragma
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
// first things that we`re gonna to do is actually deploy contract
// import our deploy scripts to make our deployment enviroment the exact same as our
// testing enviroment
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";


// we`re going to inherit everthing from this Test contract
contract FundMeTest is Test {
    FundMe fundMe;

    // we create a fake new address(fake user) to send all of our transactions
    address USER = makeAddr("user");
    // decimals don`t work in solidity but if you do 0.1 ether that makes it like below
    uint256 constant SEND_VALUE = 0.1 ether; // 1000000000000000000
    uint256 constant STARTING_BALANCE = 10 ether;
    // constant variables are actually part of contract`s bytecode, it just a pointer to 1
    uint256 constant GAS_PRICE = 1;

    // Here is where we`re going to actually deploy our contract
    function setUp() external {
        // us -> FundMeTest -> DeployFundMe(-> HelperConfig) -> FundMe
        // fundMe variable of type FundMe is a new FundMe contract
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306); // Initializing (deploy)
        // insted hardcode above,deploy DeployFundMe contract which return FundMe.sol
        DeployFundMe deployFundMe = new DeployFundMe();
        // 'run' is now going to return a FundMe contract
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE); // give our fake user 10 fake ether
    }

    function testMinimumDollarIsFive() public {
        // call MINIMUM_USD function and make sure that it`s equal to 5
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        console.log(msg.sender);
        assertEq(fundMe.getOwner(), msg.sender);
    }


    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert(); // hey, the next line should revert! == assert(This tx fails/revert)
        // remember if we want to send value, we do it in these little bracket
        // fundMe.fund{}();
        fundMe.fund(); // send 0 value
    }

    function testFundUpdateDataStructure() public {
        // we can use 'prank' to always know exactly who`s sending what call and
        // remember this only works in our tests and only with Foundry
        vm.prank(USER); // The next TX will be sent by USER
        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);

    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }
    // Using a state tree
    // Then, use empty modifiers to implement the tree
    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER); 
        vm.expectRevert(); // I said, hey the next line is should revert
        fundMe.withdraw(); 
        
    }
    
    // funded - and now it`s automatically going to get set up from modifier
    // Test withdraw with the actual owner
    function testWithdrawWithASingleFunder() public funded {
        // Introduce arrange, act, assert methoddology for working with test
        // Whenever I work with a test I always think of it mentally in this pattrn

        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act

        // we just want to vm.prank make sure we`re actually the owner
        // because only the owner can call wihdraw
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance; //cast contract to addr
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
    }

    // To simulate this tx with actual gas price we need
    // actually tell our test to pretend to use a real gas price(cheat code vm.txGasPrice)
    function testWithdrawWithASingleFunderGas() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        // Act

        // You can see how much gas you have left based on how much you send by
        // calling gasleft()
        uint256 gasStart = gasleft(); // 1000
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner()); // cost: 200
        fundMe.withdraw();
        uint256 gasEnd = gasleft(); // 800
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice; // This is how much gas we used
        // tx.gasprice (built in solidity) tells us the current gas price
        console.log(tx.gasprice);
        console.log(gasStart);
        console.log(gasEnd);
        console.log(gasUsed); // how much gas that exact call actually did

        // slot[0] 0x00...19 - hex version of the uint256(number 25)
        // so you can kind of think of



        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
    }


    
    
    // Test with multiple funders (gas: 488807)
    // It`s funded once but let`s add a ton more funders
    function testWithdrawFromMultipleFunders() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1; // you just want to make sure you`re not sending stuff to the zero addr
        // go through a loop and let`s just keep creating new addresses for this
        // number of funders and this many funders actually loop through list and
        // fund our fundMe contract
        for(uint160 i = startingFunderIndex; i < numberOfFunders; i++){
            // hoax(vm.prank+vm.deal) - sets up a prank from an address that has some eth
            hoax(address(i), SEND_VALUE); // add some ether to address
            fundMe.fund{value: SEND_VALUE}(); // we call fundMe.fund with new addrress(i) and value be send

        }

        // fund the fundMe
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act

        // This is the same start/stop.broadcast
        // it`s saying in between vm.startPrank/vm.stopPrank is going to be sent
        // pretended to be by this address here
        // It`s the syntax that I actually pefer to use
        vm.startPrank(fundMe.getOwner()); 
        fundMe.withdraw();
        vm.stopPrank();


        // Assert
        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == 
                   fundMe.getOwner().balance
                   );

    }

    function testWithdrawFromMultipleFundersCheaper() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for(uint160 i = startingFunderIndex; i < numberOfFunders; i++){
            hoax(address(i), SEND_VALUE); 
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.startPrank(fundMe.getOwner()); 
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        // Assert
        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == 
                   fundMe.getOwner().balance
                   );

    }

}
