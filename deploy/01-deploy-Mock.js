const { network, ethers } = require("hardhat");

const{developmentChains}=require("../helpers-hardhat.config");
const  BASE_FEE =ethers.utils.parseEther("0.025");
const GAS_PRICE_LINK=1e9;

module.exports = async function({getNamedAccounts,deployments}){
    

 const{deploy,log} = deployments;
 const{deployer}=await getNamedAccounts();
 const chainId=  network.config.chainId;
const args =[BASE_FEE,GAS_PRICE_LINK]
if (developmentChains.includes(network.name)) {
    console.log("localnetwork dettected ...");
    await deploy("VRFCoordinatorV2Mock",{
        from:deployer,
        log:true,
        args:args,

    })
    console.log("mocks deployed");
    console.log("__________________________________________");
 }



}
module.exports.tags=["all","mocks"]