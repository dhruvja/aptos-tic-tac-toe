module Tictactoe::tictactoe {
    use std::signer;
    use std::vector;
    use std::option;

    const EINVALID_PLAYER: u64 = 0;
    const EINVALID_INDEX: u64 = 1;
    const EALREADY_FILLED: u64 = 2;
    const EINVALID_TURN: u64 = 3;

    // Game states
    const ACTIVE: u8 = 0;
    const TIE: u8 = 1;
    const WON: u8 = 2;

    struct Game has key {
        players: vector<address>,
        board: vector<vector<u8>>,
        turn: u8,
        state: u8,
        winner: option::Option<address>,
        turns_played: u8
    }

    fun get_player_index(player_addr: address, players: &vector<address>) :u8 {
        if(player_addr == *vector::borrow(players, 0))
            1
        else if (player_addr == *vector::borrow(players, 1))
            2 
        else
            3 
    }

    // Creating a 3x3 board with default values as 0
    fun create_board() :vector<vector<u8>> {
        let board = vector::empty();
        let rows = vector::empty();
        vector::push_back(&mut rows, 0);
        vector::push_back(&mut rows, 0);
        vector::push_back(&mut rows, 0);
        vector::push_back(&mut board, rows); 
        vector::push_back(&mut board, rows); 
        vector::push_back(&mut board, rows); 
        board
    }

    fun update_board(player_index: &mut u8, row: u64, column: u64, board: &mut vector<vector<u8>>) {
        assert!(*vector::borrow(vector::borrow(board, row), column) != 0, EALREADY_FILLED);
        let board_cell = vector::borrow_mut(vector::borrow_mut(board, row), column);
        board_cell = player_index; 
    }

    fun check_winner(player_index: u8, board: &vector<vector<u8>>) :bool{
        let i = 0;
        while(i < 3){
            // Checking if all 3 in same row
            let row = vector::borrow(board, i);
            if (*vector::borrow(row, 0) == player_index && *vector::borrow(row, 1) == player_index && *vector::borrow(row, 2) == player_index) {
                return true
            }

            // Checking if all 3 in same column
            else if (*vector::borrow(vector::borrow(board, 0), i) == player_index && *vector::borrow(vector::borrow(board, 1), i) == player_index && *vector::borrow(vector::borrow(board, 2), i) == player_index) {
                return true
            };

            i = i+1;
        };
        // Checking if the 3 of the same in diagonal 
        if (*vector::borrow(vector::borrow(board, 0), 0) == player_index && *vector::borrow(vector::borrow(board, 1), 1) == player_index && *vector::borrow(vector::borrow(board, 2), 1) == player_index) {
            return true
        };

        if (*vector::borrow(vector::borrow(board, 0), 2) == player_index && *vector::borrow(vector::borrow(board, 1), 1) == player_index && *vector::borrow(vector::borrow(board, 2), 0) == player_index){
            return true
        };

        // There are no 3 consecutive of the same
        false
    }

    public entry fun start(player_one: &signer, player_two: address) {
        let player_one_addr = signer::address_of(player_one);
        let players = vector::empty();
        vector::push_back(&mut players, player_one_addr);
        vector::push_back(&mut players, player_two);
        let board = create_board();
        let game = Game {
            players: players,
            board: board,
            turn: 1,
            state: 0,
            winner: option::none(),
            turns_played: 0
        };
        move_to<Game>(player_one, game);
    }

    public entry fun play(player: &signer, game_owner: address, row: u64, column: u64) acquires Game {
        let player_addr = signer::address_of(player);
        let game = borrow_global_mut<Game>(game_owner);
        let player_index = get_player_index(player_addr, &game.players);
        assert!(player_index < 2, EINVALID_PLAYER);
        assert!(game.turn == player_index, EINVALID_TURN);
        update_board(&mut player_index, row, column, &mut game.board);
        game.turns_played = game.turns_played + 1;
        if (check_winner(player_index, &game.board) == true) {
            game.state = WON;
            game.winner = option::some(player_addr);
        }   
        else{
            if (games.turns_played == 9){
                game.state = TIE;
            }
        }
    }
}