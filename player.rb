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