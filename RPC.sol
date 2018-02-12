pragma solidity ^0.4.19;

contract RPC{
    address public owner;

    struct Player {
        bytes32 move;
        bool played;
    }
    mapping(address=>Player) moves;
    address public playerA;
    address public playerB;
    uint public playerCount;
    uint public playCount;
    uint public depositTotal;
    bool public playON;

    event LogWinner(address winningAddress);

    event RepeatPlay();
    
    //constructor
    function RPC() public  {
        owner = msg.sender;
        playerCount = 0;
        depositTotal = 0;
    }
    
    /*registerForPlay -- allow a each player to be registered 
                         if not 2 players are already registered
                         and if a player deposits more than 100000 Wei*/
    
    function registerForPlay() public payable{
        require(playerCount < 2);
        require(playON == false);
        require(msg.value >= 100000);
        
        depositTotal += msg.value;
        
        playerCount++;
        
        if(playerCount == 1){
            playerA = msg.sender;
            moves[playerA].played = false;
        }
        if(playerCount == 2){
            playerB = msg.sender;
            moves[playerB].played = false;
            playON = true;
        }
        

    }
    //modifier isPlayON() public returns(bool){return isPlayON;}
    function play(bytes32 _move) public payable{
      require(playON == true);
      require(moves[msg.sender].played == false);
      
      uint128 winner;
      bytes32 moveA;
      bytes32 moveB;
      
      moves[msg.sender].move = _move;
      moves[msg.sender].played = true;
      
      playCount++;
      if (playCount == 2){
        playCount = 0;
        playON = false;
        moveA = moves[playerA].move;
        moveB = moves[playerB].move;
        
        if (moveA == moveB){
            winner = 0;
        }
        if(moveA == "0x726f636b" && moveB == "0x73636973736f7273"){
            winner = 1;
        }
        
        if(moveA == "0x7061706572" && moveB == "0x726f636b"){
                winner = 1;
        }
        if(moveA == "0x73636973736f7273" && moveB == "0x7061706572"){
            winner = 1;
        }

        winner = 2;        
        
      }
      if (winner == 0){
          return;
      }
      if(winner == 1){
        playerA.transfer(depositTotal); 
        depositTotal = 0;
        return;
      }
      if(winner == 2){
        playerB.transfer(depositTotal); 
        depositTotal = 0;
        return;
        
      }
      
    }
    
    function endPlay() private {
        uint128 winner;

        require(playON == true);
        require(playerCount == 2);
        require(playCount == 2);
        
        playCount = 0;
        playON = false;
        
        //winner = evalWinningMove(moves[playerAddress[0]],moves[playerAddress[1]]);
        if(winner == 2){
            RepeatPlay();
        }
        else{
            /*LogWinner(playerAddress[winner]);
            
            playerAddress[winner].transfer(depositTotal);
            depositTotal = 0;*/
        }
        
        
    }
    
    function clearPlayers() public{
        require(msg.sender == owner);
        require(playON == false);
        require(playerCount == 2);
        depositTotal = 0;
        playerCount = 0;
        moves[playerA].played = false;
        moves[playerB].played = false;
        playerA = 0x00;
        playerB = 0x00;
        
    }
    
    function evalWinningMove(bytes32 moveA, bytes32 moveB) private pure returns(uint128){
        
        if (moveA == moveB){
            return 2;
        }
        if(moveA == "rock" && moveB == "scissors"){
            return 0;
        }
        
        if(moveA == "paper" && moveB == "rock"){
                return 0;
        }
        if(moveA == "scissors" && moveB == "paper"){
            return 1;
        }

        return 1;
        
        
    }

}
