class BustError < StandardError
end

class DicePolicy
  def initialize(dice)
    @dice = dice
  end

  def score
    backup_dice = @dice
    score = score_from_matching + score_from_straight + score_from_points
    if score == 0 && @dice.length == 0
      raise BustError.new
    end
    @dice = backup_dice
    score
  end

  def is_straight? 
    ( find(1) && find(2) && find(3) && find(4) && find(5) ) ||
      ( find(2) && find(3) && find(4) && find(5) && find(6) )
  end

  def matching_number
    [1,2,3,4,5,6].detect do |num|
      find_all(num).count >= 3
    end
  end
  
  def matching_dice
    find_all(matching_number)
  end

  def non_matching_dice
    @dice - matching_dice
  end

  private
  def score_from_straight
    if is_straight? then
      @dice = []
      500
    else
      0
    end
  end

  def score_from_points
    find_all(1).count * 100 + find_all(5).count * 50
  end

  def score_from_matching
    return 0 unless matching_number
    score = case matching_number
            when 1
              750
            when 2
              200
            when 3
              300
            when 4
              400
            when 5
              500
            when 6
              600
            end

    num = case matching_dice.count
          when 3
            1
          when 4
            2
          when 5
            4
          end

    @dice = @dice - matching_dice
    
    score * num
  end

  def find(number)
    @dice.detect{|d| d.current_value == number }
  end

  def find_all(number)
    @dice.find_all{|d| d.current_value == number }
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
      p dice.map(&:current_value)
      keepers = @strategy.pick(round_score, dice)
      p "Roll score: #{DicePolicy.new(keepers).score}"
      round_score = round_score + DicePolicy.new(keepers).score
      dice = dice - keepers
    end
    p "Round score: #{round_score}"
    if round_score > 1000
      p "WHAT?"
    end
    round_score
  rescue BustError => e
    p "Bust"
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
    policy = DicePolicy.new(dice)
    if policy.is_straight?
      dice
    else
     policy.matching_dice + policy.non_matching_dice.find_all{|d| d.current_value == 1 || d.current_value == 5}
    end
  end
end

Game.new([Player.new(Strategy.new)]).play


