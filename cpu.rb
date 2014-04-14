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