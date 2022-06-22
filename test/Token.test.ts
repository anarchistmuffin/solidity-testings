/* eslint-disable prettier/prettier */
import { expect } from "chai";
import { ethers, upgrades } from "hardhat";


describe("Token Environment", function () {
  before(async function () {
  this.ACL = await ethers.getContractFactory("ACLStorage");
  this.signers = await ethers.getSigners();
  this.TOKENPROXY = await ethers.getContractFactory("LabzTokenControllerLogicBeaconProxy");
  this.token = await ethers.getContractFactory("LabzToken");
  this.bfactory = await ethers.getContractFactory("LabzBeacon");
 
  });

  beforeEach(async function () {
    this.signer = this.signers[0].address;
    this.acl = await upgrades.deployProxy(this.ACL, [this.signer], {kind:"transparent", initializer: "initialize"});
    await this.acl.deployed();
    this.aclAddress = this.acl.address; // proxy address
    this.aclImpl = await upgrades.erc1967.getImplementationAddress(this.aclAddress);
   this.dToken = await  this.token.deploy();
    await this.dToken.deployed();
    this.beacon = await upgrades.deployBeacon(this.token);
    await this.beacon.deployed();
    this.beaconProxy = await upgrades.deployBeaconProxy(this.beacon, this.token, {initializer: "initialize"});
    await this.beaconProxy.deployed();
  });
 



  // Test case
  it("should have an address", async function () {
    const addr = this.acl.address;
    console.log("acl proxy address:" + this.aclAddress);
    console.log("acl implementation address:" + this.aclImpl);
    console.log("token address:" + this.dToken.address);
    console.log("beacon address:" + this.beacon.address);
    console.log("beacon proxy address:" + this.beaconProxy.address);

   // console.log(addr);
    // eslint-disable-next-line no-unused-expressions
    expect(addr).to.exist;
  });

});
