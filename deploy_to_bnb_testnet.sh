source .env
forge script script/DeployLottery.s.sol:DeployLottery --rpc-url "$BNB_TESTNET_RPC_URL" --private-key "$PRIVATE_KEY" --broadcast --etherscan-api-key "$BSCSCAN_API_KEY" --verify