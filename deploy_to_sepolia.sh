source .env
forge script script/DeployLottery.s.sol:DeployLottery --rpc-url "$SEPOLIA_RPC_URL" --private-key "$PRIVATE_KEY" --broadcast --etherscan-api-key "$ETHERSCAN_API_KEY" --verify