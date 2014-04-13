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
      STDOUT.should_receive(:puts).with("Enter coordinates for your next move as 'row(0-3), col(0-3)':")
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
end
