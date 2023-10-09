const hre = require("hardhat");

async function main() {
  const fractional = await hre.ethers.deployContract("Fractional");

  await fractional.waitForDeployment();

  console.log(`Fractional contract deployed to: ${fractional.target}`);

  await new Promise((r) => setTimeout(r, 5000));

  const chainId = await ethers.provider.getNetwork();
  if (chainId.chainId == 31337) {
    console.log(
      "Select a network other than Hardhat Network to deploy and verify contracts"
    );
  } else {
    try {
      await run(`verify:verify`, {
        address: fractional.target,
        constructorArguments: [],
      });
    } catch (e) {
      if (e.message.toLowerCase().includes("already verified")) {
        console.log("Already verified!");
      } else {
        console.log(e);
      }
    }
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

// 0x05D5a8fbB35407F0d7172008eB2CDA0935FB28aD
