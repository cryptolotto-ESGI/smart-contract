// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

contract LotteryContract {
    struct Lottery {
        uint256 id;
        address owner;
        uint256 minLaunchDate;
        uint256 ticketPrice;
        address[] players;
        address winner;
        bool isActive;
    }

    mapping(uint256 => Lottery) public lotteries;
    uint256 public lotteryCount;

    event LotteryCreated(uint256 indexed lotteryId, address indexed owner, uint256 minLaunchDate, uint256 ticketPrice);
    event TicketPurchased(uint256 indexed lotteryId, address indexed buyer);
    event LotteryLaunched(uint256 indexed lotteryId, address indexed winner);

    /**
    * @notice Creates a new lottery with a ticket price in Gwei (e.g., 100,000 Gwei for 0.0001 ETH).
    * @param _minLaunchDate Minimum timestamp to launch the lottery.
    * @param _ticketPriceInGwei Price of a ticket in Gwei (e.g., 100,000 for 0.0001 ETH).
    */
    function createLottery(uint256 _minLaunchDate, uint256 _ticketPriceInGwei) external {
        require(_minLaunchDate > block.timestamp, "The launch date must be in the future");
        require(_ticketPriceInGwei > 0, "Ticket price must be > 0");

        lotteryCount++;
        Lottery storage newLottery = lotteries[lotteryCount];

        newLottery.id = lotteryCount;
        newLottery.owner = msg.sender;
        newLottery.minLaunchDate = _minLaunchDate;
        newLottery.ticketPrice = _ticketPriceInGwei * 10 ** 9;
        newLottery.isActive = true;

        emit LotteryCreated(lotteryCount, msg.sender, _minLaunchDate, newLottery.ticketPrice);
    }

    /**
     * @notice Allows purchasing a ticket for the lottery `_lotteryId`.
     * @dev Each ticket purchase immediately sends the funds to the owner.
     * @param _lotteryId ID of the targeted lottery.
     */
    function buyTicket(uint256 _lotteryId) external {
        Lottery storage lottery = lotteries[_lotteryId];

        require(lottery.isActive, "This lottery is not active or does not exist");

/*  Simulated payment instead of requiring msg.value because payables demand too much Network Gas
        require(lottery.isActive, "Cette loterie n'est pas active ou n'existe pas");
        require(msg.value == lottery.ticketPrice, "Montant envoye incorrect pour le ticket");
*/

        // Simulate payment instead of requiring msg.value
        lottery.players.push(msg.sender);

        emit TicketPurchased(_lotteryId, msg.sender);
    }

    /**
     * @notice Launches (closes) the lottery and selects a pseudo-random winner.
     *         The ticket funds are already transferred to the owner, no additional transfers.
     * @dev Only the lottery owner can launch it after the minimum date.
     * @param _lotteryId ID of the lottery to launch.
     */
    function launchLottery(uint256 _lotteryId) external {
        Lottery storage lottery = lotteries[_lotteryId];

        require(lottery.owner == msg.sender, "You are not the creator of this lottery");
        require(lottery.isActive, "Lottery already launched or does not exist");
        require(block.timestamp >= lottery.minLaunchDate, "Minimum date not reached");
        require(lottery.players.length > 0, "No participants in this lottery");

        uint256 randomIndex = _random(lottery.players.length);
        address winnerAddress = lottery.players[randomIndex];

        lottery.winner = winnerAddress;
        lottery.isActive = false;

        emit LotteryLaunched(_lotteryId, winnerAddress);
    }

    /**
     * @notice Generates a pseudo-random number (NOT SECURE) based on blockchain data.
     * @dev NEVER use this in production for real prizes.
     * @param _modulus Used for modulo operation.
     */
    function _random(uint256 _modulus) internal view returns (uint256) {
        return uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp, // current timestamp
                    block.difficulty, // current difficulty
                    msg.sender // calling address
                )
            )
        ) % _modulus;
    }

    /**
    * @notice Gets all lotteries owned by the caller.
    * @return Array of lotteries.
    */
    function getLotteries() external view returns (Lottery[] memory) {
        Lottery[] memory result = new Lottery[](lotteryCount);
        for (uint256 i = 1; i <= lotteryCount; i++) {
            result[i - 1] = lotteries[i];
        }
        return result;
    }

    /**
    * @notice Checks if a user is in the lottery.
    * @param _lotteryId ID of the lottery.
    * @param _user Address of the user.
    * @return True if the user is in the lottery.
    */
    function isUserInLottery(uint256 _lotteryId, address _user) external view returns (bool) {
        Lottery storage lottery = lotteries[_lotteryId];
        for (uint256 i = 0; i < lottery.players.length; i++) {
            if (lottery.players[i] == _user) {
                return true;
            }
        }
        return false;
    }

    /**
    * @notice Gets the winner of a lottery.
    * @param _lotteryId ID of the lottery.
    * @return Address of the winner.
    */
    function getWinner(uint256 _lotteryId) external view returns (address) {
        require(!lotteries[_lotteryId].isActive, "Lottery is still active");
        return lotteries[_lotteryId].winner;
    }

    /**
    * @notice Cancels a lottery.
    * @param _lotteryId ID of the lottery.
    */
    function cancelLottery(uint256 _lotteryId) external {
        Lottery storage lottery = lotteries[_lotteryId];

        require(lottery.owner == msg.sender, "You are not the owner");
        require(lottery.isActive, "Lottery already launched or canceled");

        lottery.isActive = false;
    }
}