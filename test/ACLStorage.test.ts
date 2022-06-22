/* eslint-disable prettier/prettier */
import { expect } from "chai";
import { ethers, upgrades } from "hardhat";

describe("ACLStorage", function () {
  before(async function () {
  this.ACL = await ethers.getContractFactory("ACLStorage");
  this.signers = await ethers.getSigners();
 
  });

  beforeEach(async function () {
    this.signer = this.signers[0].address;
    this.acl = await upgrades.deployProxy(this.ACL, [this.signer], {kind:"transparent", initializer: "initialize"});
    await this.acl.deployed();
  });

  // Test case
  it("should have an address", async function () {
    const addr = this.acl.address;
   // console.log(addr);
    // eslint-disable-next-line no-unused-expressions
    expect(addr).to.exist;
  });
  it("signer 0 for superadmin should be true", async function () {
    const isSuperAdmin = await this.acl.isSuperAdmin(this.signer);
    // eslint-disable-next-line no-unused-expressions
    expect(isSuperAdmin).to.be.true;
  });

  it("signer 1 for superadmin should be false", async function () {
    const isSuperAdmin = await this.acl.isSuperAdmin(this.signers[1].address);
    // eslint-disable-next-line no-unused-expressions
    expect(isSuperAdmin).to.be.false;
  });

  it("should add a new role and grant role to signer 2 then verify it", async function () {
    const tx = await this.acl.addRole("TEST_ROLE");
    await tx.wait();
    const r = await this.acl.grantRole(this.signers[2].address, "TEST_ROLE", "TEST CONTRACT");
    await r.wait();

    // const coder = new ethers.utils.AbiCoder();
    // const res = coder.decode(["bytes32"],r.data);
   // console.log(res);

    // const r2 = await this.acl.getRole("TEST_ROLE");
    // console.log(r2);

    const v = await this.acl.verifyRoleForUser(this.signers[2].address, "TEST_ROLE", "TEST_CONTRACT");
    


    // eslint-disable-next-line no-unused-expressions
    expect(v).to.be.true;

  });

});
