class Board
  attr_reader :positions

  def initialize
    @positions = Array.new(3){Array.new(3)}
  end

  def set_marker(row, col, marker)
    if @positions[row][col].nil?
      @positions[row][col] = marker 
      return true
    else
      return false
    end
  end

  def clear
    @positions = Array.new(3){Array.new(3)}
  end
end