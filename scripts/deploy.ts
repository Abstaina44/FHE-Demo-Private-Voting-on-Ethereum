import { ethers } from "hardhat";

async function main() {
  const PrivateVote = await ethers.getContractFactory("PrivateVote");
  const privateVote = await PrivateVote.deploy();
  await privateVote.waitForDeployment();
  console.log(`✅ PrivateVote deployed at: ${privateVote.target}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

