pragma solidity ^0.4.0;
contract RSP {
    struct Player {
        bool whitelisted;
        bytes32 hash;
        bool played;
        uint8 move;
    }
    event Submitted(address Player, bytes32 hash);
    event Winner(address Player, uint256 prize, uint8 move);
    event Draw(uint8 move);
    event Revealed(address Player, uint8 move, string nonce);
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
        emit Submitted(msg.sender, _hash);
        return true;
        
    }
    //1: rock, 2: paper, 3: scissors
    function reveal(uint8 _move, string nonce) public onlyPlayers validMove(_move) {
        require(players[msg.sender].move == 0);
        require(players[msg.sender].hash == keccak256(_move, nonce));
        players[msg.sender].move = _move;
        emit Revealed(msg.sender, _move, nonce);
        if((players[player1].move > 0 && players[player2].move > 0)){
            if((players[player1].move == 1 && players[player2].move == 3)
                || (players[player1].move == 3 && players[player2].move == 2)
                || (players[player1].move == 2 && players[player2].move == 1) 
            ){
                player1.transfer(bet*2);
                emit Winner(player1, bet*2, players[player1].move);
            }else if(players[player1].move == players[player2].move){
                player1.transfer(bet);
                player2.transfer(bet);
                emit Draw(players[player1].move);
            }else{
                player2.transfer(bet*2);
                emit Winner(player2, bet*2, players[player2].move);
            }
            //Reset
            players[player1] = Player(true, "", false, 0);
            players[player2] = Player(true, "", false, 0);
        }
    }
}

