pragma solidity ^0.4.7;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Adoption.sol";
contract TestAdoption{
    Adoption adoption=Adoption(DeployedAddresses.Adoption());
    function testadopt() public{
        uint resultId= adoption.adopt(8);
        uint expected=8;
        Assert.equal(resultId,expected,"Aoption of pet Id 8 should be recoderd");

    }
    function testGetAdopterAdd() public{
        address expected=this;
        address adopter=adoption.adopters(8);
        Assert.equal(adopter,expected,"Aoption of pet Id 8 should be recoderd");
    }
    function testGetAdopterArray() public{
        address expected=this;
        address[16] memory adopter=adoption.getAdopters();
        Assert.equal(adopter[8],expected,"Aoption of pet Id 8 should be recoderd");
    }
}