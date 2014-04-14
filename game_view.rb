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
    puts "Enter coordinates for your next move as 'row, col' with '0,0' being the top-left:"
    move = gets.chomp.split(',').map{|num| num.to_i}
    if move.length == 2 && within_bounds?(move.first) && within_bounds?(move.last)
      return {row: move.first, col: move.last}
    else
      get_move
    end
  end

  def show(board_positions)
    board_visual = "\n"
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