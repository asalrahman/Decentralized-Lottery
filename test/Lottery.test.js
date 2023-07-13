const { getNamedAccounts, deployments, ethers, network } = require("hardhat")
const { developmentChains } = require("../helpers-hardhat.config")
const { assert ,expect} = require("chai");


!developmentChains.includes(network.name)? describe.skip :
describe("Lottery",()=>{
    let lottery,vrfCoordinatorV2Mock

beforeEach(async()=>{
    const {deployer} = await getNamedAccounts();
    await deployments.fixture(["all"]);
    lottery = await ethers.getContract("Lottery",deployer);
    vrfCoordinatorV2Mock = await ethers.getContract("VRFCoordinatorV2Mock",deployer)
});

describe("constructor",async()=>{
    it('initialize lottery correctly',async()=>{
        const lotteryState = await lottery.getLotterySate();
        assert.equal(lotteryState.toString(),"0")
    });
});



});