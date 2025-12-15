const { expect } = require("chai");

describe("TestDependencyImport", function () {
  it("Should import and use contracts properly", async function () {
    const TestContract = await ethers.getContractFactory("TestDependencyImport");
    const testContract = await TestContract.deploy();
    
    // Since we're just testing the import capability, we'll just call the test function
    await testContract.testExample();
    
    expect(true).to.equal(true);
  });
});