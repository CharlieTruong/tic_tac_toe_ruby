require_relative 'cpu'
require_relative 'player'
require_relative 'board'
require_relative 'game_view'

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
    @won = false
    start
  end

  def player_move
    @game_view.show(@board.positions)
    move = @game_view.get_move
    move = @game_view.get_move while !@board.positions[move[:row]][move[:col]].nil?
    @board.set_marker(move[:row], move[:col], @player.marker)
    @won = @cpu.check_winner(@board.positions)
  end

  def cpu_move
    move = @cpu.next_move(@board.positions)
    @board.set_marker(move[:row], move[:col], @cpu.marker)
    @won = @cpu.check_winner(@board.positions)
  end

  def start
    setup
    game_loop
    end_game
  end

  private

  def game_loop
    cpu_move if @player.turn == 'last'
    while @won == false
      player_move
      break if @won != false
      cpu_move
    end
  end

  def setup
    player_marker = @game_view.get_player_marker
    player_turn = @game_view.get_player_turn
    @player.set_params(player_marker, player_turn)
    @cpu.set_marker(@player.marker)
  end

  def identify_winner
    if @won == @player.marker
      'player'
    elsif @won == @cpu.marker
      'cpu'
    else
      'tie'
    end
  end

  def end_game
    @game_view.show(@board.positions)
    winner = identify_winner
    @game_view.declare_winner(winner)
    reset if @game_view.new_game?
  end
end
