require_relative 'tic_tac_toe'

describe Board do
  
  before(:each) do
    @board = Board.new
  end

  describe '#positions' do
    it 'returns a 3 x 3 array' do
      expect(@board.positions.length).to eq(3)
      expect(@board.positions[0].length).to eq(3)
    end
  end

  describe '#set_marker' do
    it 'sets a marker at the given row and column' do
      @board.set_marker(0, 0, 'X')
      expect(@board.positions[0][0]).to eq('X')
    end

    context 'requested marker position empty' do
      it 'returns true' do
        expect(@board.set_marker(0, 0, 'X')).to eq(true)
      end
    end

    context 'requested marker position already taken' do
      it 'returns false' do
        @board.set_marker(0, 0, 'O')
        expect(@board.set_marker(0, 0, 'X')).to eq(false)
      end
    end
  end

  describe '#clear' do
    it 'empties the #positions array' do
      @board.set_marker(0, 0, 'O')
      @board.set_marker(1, 1, 'X')
      @board.clear
      expect(@board.positions.flatten.uniq).to eq([nil])
    end
  end

  describe '#num_space_remaining' do
    it 'returns the number of empty positions' do
      @board.set_marker(0, 0, 'O')
      @board.set_marker(1, 1, 'X')
      expect(@board.num_space_remaining).to eq(7)
    end
  end
end

describe Player do 
  
  before(:each) do
    @player = Player.new
  end
  
  describe '#set_params' do 
    it 'sets the player marker and turn preferences' do
      @player.set_params('X', 'last')
      expect(@player.marker).to eq('X')
      expect(@player.turn).to eq('last')
    end
  end
end

describe GameView do
  before(:each) do
    @game_view = GameView.new
    STDOUT.stub(:puts)
  end

  describe '#get_player_marker' do
    it 'prints a message to get the marker preference' do
      STDOUT.should_receive(:puts).with('Choose your marker(1 = X, 2 = O):')
      @game_view.stub(:gets){'1'}
      @game_view.get_player_marker
    end

    context 'option 1' do
      it 'returns X' do
        @game_view.stub(:gets){'1'}
        expect(@game_view.get_player_marker).to eq('X')
      end
    end

    context 'option 2' do
      it 'returns O' do
        @game_view.stub(:gets){'2'}
        expect(@game_view.get_player_marker).to eq('O')
      end
    end

    context 'invalid option' do
      it 'repeats the request until there is a valid selection' do
        @game_view.stub(:gets).and_return('3', '1')
        expect(@game_view.get_player_marker).to eq('X')
      end
    end
  end

  describe '#get_player_turn' do
    it 'prints a message to get the turn order preference' do
      STDOUT.should_receive(:puts).with('Choose to go first or last (1 = first, 2 = last):')
      @game_view.stub(:gets){'1'}
      @game_view.get_player_turn
    end

    context 'option 1' do
      it 'returns first' do
        @game_view.stub(:gets){'1'}
        expect(@game_view.get_player_turn).to eq('first')
      end
    end

    context 'option 2' do
      it 'returns last' do
        @game_view.stub(:gets){'2'}
        expect(@game_view.get_player_turn).to eq('last')
      end
    end

    context 'invalid option' do
      it 'repeats the request until there is a valid selection' do
        @game_view.stub(:gets).and_return('3', '1')
        expect(@game_view.get_player_turn).to eq('first')
      end
    end
  end

  describe '#new_game?' do
    it 'prints a message to ask if the player wants to play again' do
      STDOUT.should_receive(:puts).with('Do you want to play again?(y/n)')
      @game_view.stub(:gets){'y'}
      @game_view.new_game?
    end

    context 'yes' do
      it 'returns true' do
        @game_view.stub(:gets){'y'}
        expect(@game_view.new_game?).to eq(true)
      end
    end

    context 'no' do
      it 'returns false' do
        @game_view.stub(:gets){'n'}
        expect(@game_view.new_game?).to eq(false)
      end
    end

    context 'invalid option' do
      it 'repeats the request until there is a valid selection' do
        @game_view.stub(:gets).and_return('z', 'y')
        expect(@game_view.new_game?).to eq(true)
      end
    end
  end

  describe '#get_move' do
    it 'prints a message to ask for the player move' do
      STDOUT.should_receive(:puts).with("Enter coordinates for your next move as 'row(0-2), col(0-2)':")
      @game_view.stub(:gets){'0,0'}
      @game_view.get_move
    end

    it 'returns a hash of the player move' do
      @game_view.stub(:gets){'1,1'}
      expect(@game_view.get_move).to eq({row: 1, col: 1})
    end

    context 'invalid coordinates' do
      it 'repeats the request until there is a valid selection' do
        @game_view.stub(:gets).and_return('0,5','1,2')
        expect(@game_view.get_move).to eq({row: 1, col: 2}) 
      end
    end
  end

  describe '#show' do
    it 'prints a board with the current markers placed' do
      board_positions = [['X',nil,nil],[nil,'O',nil],[nil,nil,'X']]
      expected_output = "X| | \n |O| \n | |X\n"
      STDOUT.should_receive(:puts).with(expected_output)
      @game_view.show(board_positions)
    end
  end

  describe '#declare_winner' do
    context 'player wins' do
      it 'prints that the player won' do
        STDOUT.should_receive(:puts).with('You won!')
        @game_view.declare_winner('player')
      end
    end

    context 'player lost' do
      it 'prints that the player lost' do
        STDOUT.should_receive(:puts).with('You lost!')
        @game_view.declare_winner('cpu')
      end
    end

    context 'tie' do
      it 'prints there was a tie' do
        STDOUT.should_receive(:puts).with('It\'s a tie!')
        @game_view.declare_winner('tie')
      end
    end
  end
end

describe Game do
  before(:each) do
    @game = Game.new
    @game.instance_variable_set(:@board, double('board'))
    @game.instance_variable_set(:@game_view, double('game_view'))
    @game.instance_variable_set(:@cpu, double('cpu'))
  end

  describe '#reset' do
    before(:each) do
      @game.stub(:start)
      @game.instance_variable_get(:@board).stub(:clear)
    end

    it 'calls board#clear' do
      @game.instance_variable_get(:@board).should_receive(:clear) 
      @game.reset
    end

    it 'calls #start' do
      @game.should_receive(:start)
      @game.reset
    end
  end

  describe '#player_move' do
    before(:each) do
      @game.instance_variable_get(:@game_view).stub(:get_move).and_return({row: 0, col: 0})
      @game.instance_variable_get(:@board).stub(:set_marker)
      @game.instance_variable_get(:@board).stub(:positions)
      @game.instance_variable_get(:@player).stub(:marker).and_return('X')
      @game.instance_variable_get(:@cpu).stub(:check_winner).and_return('X')
    end

    it 'calls game_view#get_move' do
      @game.instance_variable_get(:@game_view).should_receive(:get_move)
      @game.player_move
    end

    it 'calls board#set_marker with the results of game_view#get_move' do
      @game.instance_variable_get(:@board).should_receive(:set_marker).with(0, 0, 'X')
      @game.player_move
    end

    it 'checks for the winner and sets it in game#won' do
      @game.player_move
      expect(@game.instance_variable_get(:@won)).to eq('X')
    end
  end
end

describe CPU do
  before(:each) do
    @cpu = CPU.new
  end

  describe '#set_marker' do
    it 'sets the cpu\'s marker based on the player marker' do 
      @cpu.set_marker('X')
      expect(@cpu.marker).to eq('O')
    end

    it 'sets the player\'s marker' do
      @cpu.set_marker('X')
      expect(@cpu.player_marker).to eq('X')
    end
  end

  describe '#check_game_over' do
    it 'returns the marker that has 3 consecutive horizontal positions' do
      board_positions = [[nil,nil,nil],['X','X','X'],[nil,nil,nil]]
      expect(@cpu.check_winner(board_positions)).to eq('X')
    end

    it 'returns the marker that has 3 consecutive vertical positions' do
      board_positions = [[nil,nil,'O'],[nil,nil,'O'],[nil,nil,'O']]
      expect(@cpu.check_winner(board_positions)).to eq('O')
    end

    it 'returns the marker that has 3 consecutive diagonal positions' do
      board_positions = [[nil,nil,'O'],[nil,'O',nil],['O',nil,nil]]
      expect(@cpu.check_winner(board_positions)).to eq('O')
    end

    it "returns 'tie' if all spaces are filled with no winner" do
      board_positions = [['O','X','O'],['O','X','X'],['X','O','O']]
      expect(@cpu.check_winner(board_positions)).to eq('tie')
    end
  end

  describe '#next_move' do
    before(:each) do
      @cpu.instance_variable_set(:@marker, 'X')
      @cpu.instance_variable_set(:@player_marker, 'O')
    end

    it 'takes the upper left corner if the cpu moves first' do
      board_positions = [[nil,nil,nil],[nil,nil,nil],[nil,nil,nil]]
      expect(@cpu.next_move(board_positions)).to eq({row: 0, col: 0})
    end

    it 'takes the center if the player took a corner first' do
      board_positions = [['X',nil,nil],[nil,nil,nil],[nil,nil,nil]]
      expect(@cpu.next_move(board_positions)).to eq({row: 1, col: 1})
    end

    it 'takes the winning move if available' do
      board_positions = [[nil,nil,nil],['X','X',nil],[nil,nil,nil]]
      expect(@cpu.next_move(board_positions)).to eq({row: 1, col: 2})
    end

    it 'blocks the player\'s winning move' do
      board_positions = [[nil,nil,'O'],[nil,nil,nil],['O',nil,nil]]
      expect(@cpu.next_move(board_positions)).to eq({row: 1, col: 1})
    end

    it 'creates a fork for two chances to win' do
      board_positions = [['X',nil,nil],[nil,'O',nil],[nil,nil,'X']]
      expect(@cpu.next_move(board_positions)).to eq({row: 0, col: 2})
    end

    it 'blocks the player from forking' do
      board_positions = [['O',nil,nil],[nil,'X',nil],[nil,nil,'O']]
      expect(@cpu.next_move(board_positions)).to eq({row: 0, col: 1})
    end

    it 'takes the center if none of the above moves exist' do
      board_positions = [['X',nil,nil],[nil,nil,nil],[nil,'O',nil]]
      expect(@cpu.next_move(board_positions)).to eq({row: 1, col: 1})
    end

    it 'takes the opposite corner of a player if the above moves do not exist' do
      board_positions = [['O',nil,nil],[nil,'X',nil],[nil,nil,nil]]
      expect(@cpu.next_move(board_positions)).to eq({row: 2, col: 2})
    end

    it 'takes an empty corner if the above moves do not exist' do
      board_positions = [[nil,'X',nil],[nil,'O',nil],[nil,nil,nil]]
      expect(@cpu.next_move(board_positions)).to eq({row: 0, col: 0})
    end

    it 'takes an available side if the above moves do not exist' do
      board_positions = [['Y','Y','Y'],['Y','Y','Y'],['Y',nil,'Y']]
      expect(@cpu.next_move(board_positions)).to eq({row: 2, col: 1})
    end
  end
end