import { HardhatRuntimeEnvironment } from "hardhat/types";

export default async (hre: HardhatRuntimeEnvironment) => {
    const { deployer } = await hre.getNamedAccounts();

    const demo = await hre.deployments.deploy("GameToken", {
        from: deployer,
        proxy: {
            execute: {
                init: {
                    methodName: "initialize",
                    args: [deployer],
                },
            },
            proxyContract: "OpenZeppelinTransparentProxy",
        },
        log: true,
    });

    console.log("GameToken Deployed at:", demo.address, demo.newlyDeployed);
};
