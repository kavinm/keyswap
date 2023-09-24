import { ethers } from "hardhat";

const main = async () => {
  const accounts = await ethers.getSigners();
  const deployerAddress = accounts[0].address; // Get the address of the first account
  const friendtechFactory = await ethers.getContractFactory(
    "FriendtechSharesV1"
  );
  const friendtechContract = await friendtechFactory.deploy();
  await friendtechContract.deployed();
  console.log(`Contract deployed at ${friendtechContract.address}`);

  // Setting Fee Destination
  const feeDestinationTx = await friendtechContract.setFeeDestination(
    "0xA260747C2C5aC0f8741e6C5d2F0976615bfE6b84"
  );
  await feeDestinationTx.wait();

  // Setting protocol fee
  const protocolFeeTx = await friendtechContract.setProtocolFeePercent(1);
  await protocolFeeTx.wait();

  //Setting subject fee
  const subjectFeeTx = await friendtechContract.setSubjectFeePercent(1);
  await subjectFeeTx.wait();

  const [feeDestination, protocolFee, subjectFee] = await Promise.all([
    friendtechContract.protocolFeeDestination(),
    friendtechContract.protocolFeePercent(),
    friendtechContract.subjectFeePercent(),
  ]);
  console.log({ feeDestination, protocolFee, subjectFee });

  //buying deployer's shares
  const valueToSend = ethers.utils.parseEther("0.05"); // This will convert ether to wei

  const buyAmount = ethers.utils.parseEther("2");
  console.log("BUYING SHARES");
  const buyTx = await friendtechContract.buyShares(deployerAddress, buyAmount, {
    value: valueToSend,
  });
  await buyTx.wait();
  console.log("DONE BUYING SHARES");
  const sharesBefore = await friendtechContract.sharesBalance(
    deployerAddress,
    deployerAddress
  );
  console.log(sharesBefore);

  const sellAmount = ethers.utils.parseEther("1");
  const sellTx = await friendtechContract.sellShares(
    deployerAddress,
    sellAmount
  );
  await sellTx.wait();

  const sharesAfter = await friendtechContract.sharesBalance(
    deployerAddress,
    deployerAddress
  );
  console.log(sharesAfter);
};

main().catch((err) => {
  console.error(err);
  process.exitCode = 1;
});
