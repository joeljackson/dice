class BustError < StandardError
end

class DicePolicy
  def initialize(dice)
    @dice = dice
  end

  def score
    score = @dice.find_all{|d| d.current_value == 1 }.count * 100 + @dice.find_all{|d| d.current_value == 5 }.count * 50
    if score == 0 && @dice.length == 0
      raise BustError.new
    end
    score
  end
end

class Die
  attr_accessor :current_value

  def roll
    @current_value = rand(6) + 1
  end
end

class Player
  attr_accessor :score
  
  def initialize(strategy)
    @score = 0
    @strategy = strategy
  end

  def play_round
    round_score = 0
    dice = 5.times.map{ Die.new }
    
    while dice.count > 0 do
      dice.each(&:roll)
      keepers = @strategy.pick(round_score, dice)
      round_score = round_score + DicePolicy.new(keepers).score
      dice = dice - keepers
    end
    round_score
  rescue BustError => e
    0
  end
end

class Game
  NUM_ROUNDS = 20

  def initialize(players)
    @players = players
  end

  def play
    NUM_ROUNDS.times do
      @players.each do |player|
        player.score = player.score + player.play_round
      end
    end
    p @players.map(&:score)
  end
end

class Strategy
  def pick(round_score, dice)
    dice.find_all{|d| d.current_value == 1 || d.current_value == 5}
  end
end

Game.new([Player.new(Strategy.new)]).play


