import { ethers } from "hardhat";

const main = async () => {
  const accounts = await ethers.getSigners();
  const deployerAddress = accounts[0].address; // Get the address of the first account

  console.log("Deploying WrappedFriendFactory...");
  const friendtechFactory = await ethers.getContractFactory(
    "WrappedFriendFactory"
  );
  const wrappedFriendContract = await friendtechFactory.deploy();
  await wrappedFriendContract.deployed();
  console.log(
    `WrappedFriendFactory deployed at ${wrappedFriendContract.address}`
  );
};

main().catch((err) => {
  console.error(err);
  process.exitCode = 1;
});
