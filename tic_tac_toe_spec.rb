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