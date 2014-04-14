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

  def num_space_remaining
    @positions.flatten.select(&:nil?).length
  end
end

class Player
  attr_reader :marker, :turn

  def initialize
    @marker = String.new
    @turn = String.new
  end

  def set_params(marker, turn)
    @marker = marker
    @turn = turn
  end
end

class GameView
  def get_player_marker
    puts 'Choose your marker(1 = X, 2 = O):'
    case gets.chomp
      when '1' then return 'X'
      when '2' then return 'O'
      else get_player_marker
    end
  end

  def get_player_turn
    puts 'Choose to go first or last (1 = first, 2 = last):'
    case gets.chomp
      when '1' then return 'first'
      when '2' then return 'last'
      else get_player_turn
    end
  end

  def new_game?
    puts 'Do you want to play again?(y/n)'
    case gets.chomp
      when 'y' then return true
      when 'n' then return false
      else new_game?
    end
  end

  def get_move
    puts "Enter coordinates for your next move as 'row(0-2), col(0-2)':"
    move = gets.chomp.split(',').map{|num| num.to_i}
    if move.length == 2 && within_bounds?(move.first) && within_bounds?(move.last)
      return {row: move.first, col: move.last}
    else
      get_move
    end
  end

  def show(board_positions)
    board_visual = String.new
    for row in 0...board_positions.length do 
      for col in 0...board_positions.first.length do
        board_visual += transform_to_s(col, board_positions[row][col])
      end
    end
    puts board_visual
  end

  def declare_winner(winner)
    if winner == 'player'
      puts 'You won!'
    elsif winner == 'cpu'
      puts 'You lost!'
    elsif winner == 'tie'
      puts 'It\'s a tie!'
    end
  end

  private

  def within_bounds?(num)
    num >= 0 && num < 3
  end

  def transform_to_s(index, value)
    index == 1 ? border = "|" : border = ""
    index == 2 ? newline = "\n" : newline = ""
    value = " " if value.nil?
    return border + value + border + newline
  end
end

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

  def next_move(board_positions)
    win = win_assess(@marker, board_positions)
    block = win_assess(@player_marker, board_positions)
    fork = fork_assess(@marker, board_positions)
    block_fork = block_fork_assess(@marker, @player_marker, board_positions)
    opposite_corner = opposite_corner_assess(@player_marker, board_positions)
    any_corner = any_corner_assess(board_positions)
    any_side = any_side_assess(board_positions)

    if empty_spaces(board_positions).length == 9
      {row: 0, col: 0}
    elsif corner_taken(board_positions) && empty_spaces(board_positions).length == 8
      {row: 1, col: 1}
    elsif win[:possible]
      {row: win[:row], col: win[:col]}
    elsif block[:possible]
      {row: block[:row], col: block[:col]}
    elsif fork[:possible]
      {row: fork[:row], col: fork[:col]}
    elsif block_fork[:possible]
      {row: block_fork[:row], col: block_fork[:col]}
    elsif board_positions[1][1].nil?
      {row: 1, col: 1}
    elsif opposite_corner[:possible]
      {row: opposite_corner[:row], col: opposite_corner[:col]}
    elsif any_corner[:possible]
      {row: any_corner[:row], col: any_corner[:col]}
    elsif any_side[:possible]
      {row: any_side[:row], col: any_side[:col]}
    end
  end

  private 

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

  def empty_spaces(board_positions)
    empty = Array.new
    for row in 0...board_positions.length
      for col in 0...board_positions.first.length
        empty.push({row: row, col: col}) if board_positions[row][col].nil?
      end
    end
    empty
  end

  def corner_taken(board_positions)
    !board_positions[0][0].nil? || !board_positions[0][2].nil? || !board_positions[2][2].nil? || !board_positions[2][0].nil?
  end

  def win_assess(marker, board_positions)
    assessment = {possible: false}
    empty_spaces(board_positions).each do |space|
      scenario = create_scenario(space[:row], space[:col], marker, board_positions)
      if check_winner(scenario) == marker 
        assessment = {possible: true, row: space[:row], col: space[:col]} 
        break
      end
    end
    assessment
  end

  def fork_assess(marker, board_positions)
    assessment = {possible: false}
    empty_spaces(board_positions).each do |space|
      scenario = create_scenario(space[:row], space[:col], marker, board_positions)
      if win_possible_count(marker, scenario) == 2
        assessment = {possible: true, row: space[:row], col: space[:col]} 
        break
      end
    end
    assessment
  end

  def win_possible_count(marker, board_positions)
    win_count = 0
    empty_spaces(board_positions).each do |space|
      scenario = create_scenario(space[:row], space[:col], marker, board_positions)
      win_count += 1 if check_winner(scenario) == marker 
    end
    win_count
  end

  def create_scenario(row, col, marker, board_positions)
    scenario = Marshal.load(Marshal.dump(board_positions))
    scenario[row][col] = marker
    scenario
  end

  def block_fork_assess(marker, player_marker, board_positions)
    assessment = {possible: false}
    if fork_assess(player_marker, board_positions)[:possible]
      empty_spaces(board_positions).each do |space|
        scenario = create_scenario(space[:row], space[:col], marker, board_positions)
        win = win_assess(marker, scenario)
        if win[:possible] == true && !creates_player_fork?(win[:row], win[:col], player_marker, scenario) 
          assessment = {possible: true, row: space[:row], col: space[:col]} 
          break
        end
      end
    end
    assessment
  end

  def creates_player_fork?(row, col, player_marker, board_positions)
    scenario = create_scenario(row, col, player_marker, board_positions)
    return win_possible_count(player_marker, scenario) == 2 ? true : false
  end

  def opposite_corner_assess(player_marker, board_positions)
    assessment = {possible: false}
    corners = [{row: 0, col: 0}, {row: 0, col: 2}, {row: 2, col: 0}, {row: 2, col: 2}]
    opposite = [{row: 2, col: 2}, {row: 2, col: 0}, {row: 0, col: 2}, {row: 0, col: 0}]
    for x in 0...corners.length do 
      if board_positions[corners[x][:row]][corners[x][:col]] == player_marker && board_positions[opposite[x][:row]][opposite[x][:col]].nil?
        assessment = {possible: true, row: opposite[x][:row], col: opposite[x][:col]}  
        break
      end
    end
    assessment
  end

  def any_corner_assess(board_positions)
    assessment = {possible: false}
    corners = [{row: 0, col: 0}, {row: 0, col: 2}, {row: 2, col: 0}, {row: 2, col: 2}]
    corners.each do |corner| 
      if board_positions[corner[:row]][corner[:col]].nil?
        assessment = {possible: true, row: corner[:row], col: corner[:col]}
        break
      end
    end
    assessment
  end

  def any_side_assess(board_positions)
    assessment = {possible: false}
    sides = [{row: 0, col: 1}, {row: 1, col: 0}, {row: 1, col: 2}, {row: 2, col: 1}]
    sides.each do |side| 
      if board_positions[side[:row]][side[:col]].nil?
        assessment = {possible: true, row: side[:row], col: side[:col]}
        break
      end
    end
    assessment
  end
end

class Game
  def initialize
    @won = false
    @board = Board.new
    @game_view = GameView.new
    @player = Player.new
    @cpu = CPU.new
  end

  def reset
    @board.clear
    start
  end

  def player_move
    move = @game_view.get_move
    @board.set_marker(move[:row], move[:col], @player.marker)
    @won = @cpu.check_winner(@board.positions)
  end
end
