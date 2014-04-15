class CPU
  attr_reader :marker, :player_marker

  def initialize
    @marker = String.new
    @player_marker = String.new
  end

  def set_marker(player_marker)
    @player_marker = player_marker
    @player_marker == 'X' ? @marker = 'O' : @marker = 'X'
  end

  def check_winner(board_positions)
    winner = check_horizontal(board_positions) || check_vertical(board_positions) || check_diagonal(board_positions)
    winner = 'tie' if winner == false && empty_spaces(board_positions).length == 0
    winner
  end

  def next_move(marker1, marker2, board_positions, level = 0)
    possible_moves = Array.new
    winner = check_winner(board_positions)
    return rank(level, winner, marker2, board_positions) if winner != false

    empty_spaces(board_positions).each do |space|
      scenario = create_scenario(space[:row], space[:col], marker1, board_positions)
      space[:level] = level
      space[:rank] = next_move(marker2, marker1, scenario, level + 1) 
      possible_moves.push(space)
    end
    
    return best_choice(level, marker1, possible_moves)
  end

  private 

  def best_choice(level, marker, possible_moves)
    if level == 0
      move = possible_moves.max_by{|space| space[:rank]}
      return {row: move[:row], col: move[:col]}
    elsif marker == @marker 
      return possible_moves.max_by{|space| space[:rank]}[:rank]
    else
      return possible_moves.min_by{|space| space[:rank]}[:rank]
    end
  end

  def rank(level, winner, marker, board_positions)
    if winner == marker && marker == @marker
      return 10 - level
    elsif winner == marker && marker == @player_marker
      return level -10
    elsif winner == 'tie'
      return 0
    end
  end

  def check_horizontal(board_positions)
    winner = false
    board_positions.each do |row|
      winner = row.first if row.uniq.length == 1 && !row.uniq.first.nil?
    end
    winner
  end

  def check_vertical(board_positions)
    winner = false
    board_positions.transpose.each do |col|
      winner = col.first if col.uniq.length == 1 && !col.uniq.first.nil?
    end
    winner
  end

  def check_diagonal(board_positions)
    winner = false
    diag_1 = [board_positions[0][0], board_positions[1][1], board_positions[2][2]]
    diag_2 = [board_positions[0][2], board_positions[1][1], board_positions[2][0]]
    winner = diag_1.first if diag_1.uniq.length == 1 && !diag_1.first.nil?
    winner = diag_2.first if diag_2.uniq.length == 1 && !diag_2.first.nil?
    winner
  end

  def create_scenario(row, col, marker, board_positions)
    scenario = Marshal.load(Marshal.dump(board_positions))
    scenario[row][col] = marker
    scenario
  end

  def empty_spaces(board_positions)
    empty = Array.new
    for row in 0...board_positions.length
      for col in 0...board_positions.first.length
        empty.push({row: row, col: col}) if board_positions[row][col].nil?
      end
    end
    empty
  end
end