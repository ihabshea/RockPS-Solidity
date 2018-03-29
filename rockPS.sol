pragma solidity ^0.4.0;
contract RSP {
    struct Player {
        bool whitelisted;
        bytes32 hash;
        bool played;
        uint8 move;
    }
    mapping (address => Player) public players;
    uint public bet;
    address player1; address player2;
    function RSP(uint _bet, address _player1, address _player2) public {
        bet = _bet;
        player1 = _player1;
        player2 =  _player2;
        players[player1] = Player(true, "", false, 0);
        players[player2] = Player(true, "", false, 0);
    }
    modifier validMove(uint8 thisMove){
        require(thisMove > 0 && thisMove <= 3);
        _;
    }
    modifier onlyPlayers {
        require(players[msg.sender].whitelisted);
        _;
    }
    function generateHash(uint8 _move, string nonce) public pure validMove(_move) returns(bytes32) {
        return keccak256(_move, nonce);
    }
    function submit(bytes32 _hash) public payable onlyPlayers returns (bool){
        require(!players[msg.sender].played);
        require(msg.value == bet);
        Player storage thisPlayer = players[msg.sender];
        thisPlayer.hash = _hash;
        thisPlayer.played = true;
        return true;
    }
    //1: rock, 2: paper, 3: scissors
    function reveal(uint8 _move, string nonce) public onlyPlayers validMove(_move) returns (string){
        require(players[msg.sender].move == 0);
        require(players[msg.sender].hash == keccak256(_move, nonce));
        players[msg.sender].move = _move;
        if(players[player1].move > 0 && players[player2].move > 0){
            if(players[player1].move == 1 && players[player2].move == 3){
                player1.transfer(bet*2);
                return "Player 1 won ya kossomak.";
            }else if(players[player1].move == 2 && players[player2].move == 1){
                player1.transfer(bet*2);
                return "Player 1 won ya kossomak.";
            }else if(players[player1].move == 3 && players[player2].move == 2){
                player1.transfer(bet*2);
                return "Player 1 won ya kossomak.";
            }else if(players[player1].move == players[player2].move){
                player1.transfer(bet);
                player2.transfer(bet);
                return "Draw";  
            }else{
                player2.transfer(bet*2);
                return "Player 2 won ya kossomak.";
            }
            //Reset
            players[player1] = Player(true, "", false, 0);
            players[player2] = Player(true, "", false, 0);
        }else{
            return "Well played.";
        }
        return "Well played";
    }
}
