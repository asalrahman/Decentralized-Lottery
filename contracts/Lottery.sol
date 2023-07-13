// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AutomationCompatibleInterface.sol";
// errors
 error Lottery__SendMoreToEnter();
error Lottery__TransferFailed();
error Lottery_LotteryNotOpen();
error  Lottery_UpKeepNotNeeded(uint256 currentBalance, uint256 numPlayers, uint256 lotteryState);


contract Lottery is VRFConsumerBaseV2 ,AutomationCompatibleInterface{

     //types 
     enum LotteryState {
        OPEN,
        CALCULATING //open =0,calculating =1
     }
     


    // state variables
    uint256 public immutable i_entranceFee;
    address payable[] private s_players;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant requestConfirmations = 3;
    uint32 private constant NUM_WORDS =1;

   //   Lottery statevariables
   address private s_recentWinner;
   LotteryState private s_lotteryState;
    uint256 public immutable i_interval;
    uint256  private s_lastTimeStamp;

    // events
    event LotteryEnter(address indexed player);
    event RequestedLotteryWinner(uint256 indexed requestId);
    event winnerPicked(address indexed Winner);

     constructor( address vrfCoordinatorV2,
        uint64 subscriptionId,
        bytes32 gasLane, // keyHash
        uint256 interval,
        uint256 entranceFee,
        uint32 callbackGasLimit) VRFConsumerBaseV2(vrfCoordinatorV2) {

        i_entranceFee= entranceFee;
        i_vrfCoordinator=VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_gasLane = gasLane;
        i_subscriptionId =subscriptionId;
        i_callbackGasLimit =callbackGasLimit;
        s_lotteryState = LotteryState.OPEN;
        i_interval = interval;
        s_lastTimeStamp =block.timestamp;
    }

    function enterLottery() public payable {
        if (msg.value < i_entranceFee) {
            revert Lottery__SendMoreToEnter();
        }
        if(s_lotteryState != LotteryState.OPEN){
            revert Lottery_LotteryNotOpen();
        }
        s_players.push(payable(msg.sender));
        emit LotteryEnter(msg.sender);
    }


    //if checkupkeep is true then it will go to next
    //shoul be in open state
    //have enough eth
    //time interval
    //nee players
     function checkUpkeep( bytes memory /* checkData */) public view override
        returns (bool upkeepNeeded, bytes memory /* performData */)
    {
       bool isOpen = ( LotteryState.OPEN == s_lotteryState);
       bool timePassed = (block.timestamp - s_lastTimeStamp) > i_interval;
       bool hasPlayers= s_players.length >0;
       bool hasBalance = address(this).balance > 0;
       upkeepNeeded =(timePassed && isOpen && hasBalance && hasPlayers);
        
    }
    


// first request the the random numbers
//then do with it
     function performUpkeep(bytes calldata /* performData */) external override{
      
      //wants to checkupkeep is true
      (bool upkeepNeeded,) = checkUpkeep("");
      if (!upkeepNeeded) { 
        revert Lottery_UpKeepNotNeeded(address(this).balance,
                s_players.length,
                uint256(s_lotteryState));
        
      }

        s_lotteryState = LotteryState.CALCULATING;
      uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            requestConfirmations,
            i_callbackGasLimit,
            NUM_WORDS
        );
    emit RequestedLotteryWinner(requestId);
    }


//once we get random number module it by aray.leng 
     function fulfillRandomWords(uint256 /* requestId */, uint256[] memory randomWords)
      internal override{
          uint256 randomWinnerIndex = randomWords[0] % s_players.length;
          address payable recentWinner = s_players[randomWinnerIndex];
          s_recentWinner = recentWinner;
          s_lotteryState = LotteryState.OPEN; // join users again to lottery
          s_players = new address payable[](0); // rest players array
          s_lastTimeStamp = block.timestamp;
           (bool success, ) = recentWinner.call{value: address(this).balance}("");
        // require(success, "Transfer failed");
        if (!success) {
            revert Lottery__TransferFailed();
        }
          emit winnerPicked(recentWinner);
      }





    // view/pure functions
    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }

    function getPlayers(uint256 index) public view returns (address) {
        return s_players[index];
    }
    
    function getReecentWinner ()public view returns(address){
        return s_recentWinner;
    }
    function getLotterySate()public view returns(LotteryState){
       return s_lotteryState;
    }
    function getNumOfWords()public pure returns(uint256){
        return NUM_WORDS;
    }
    function getLtestTimeSatamb() public view returns (uint256){
        return s_lastTimeStamp;
    }
    function getRequestConfirmations() public pure returns(uint256) {
        return requestConfirmations;
    }
  function getNumOfPlayers() public view returns(uint256){
    return s_players.length;
  }
  function getInterval() public view returns(uint256)
{
    return i_interval;
}}
