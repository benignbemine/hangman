require "yaml"

#Hangman
class Game

  def initialize(player_name)
    @game_word = get_secret_word
    @game_spaces = get_empty_template(@game_word)
    @TOTAL_CHANCES = 10
    @name = player_name
    @guesses_guessed = []
  end

  #Get random word from dictionary. Return as array
  def get_secret_word
    secret_word = ""
    until secret_word.length >= 5 && secret_word.length <= 12
      secret_word = File.readlines("5desk.txt").sample.strip.downcase
    end
    secret_word
  end

  #Get empty template
  def get_empty_template(secret_word)
    number_of_spaces = secret_word.length
    progress = []
    number_of_spaces.times { progress << "_" }
    progress
  end

  def get_guess
    puts "#{@name}, Please guess a letter\n"
    while guess = gets.chomp
      if guess.match(/^[a-z]$/) && !@guesses_guessed.include?(guess)
        break
      else
        puts "Invalid input. Please enter a single lower-case letter that you have not already guessed"
      end
    end
    @guesses_guessed << guess
    guess
  end

  #checks guess and outputs updated spaces
  def process_guess(guess)
    if @game_word.include?(guess)
      indices = (0..@game_word.length-1).find_all{|i| @game_word[i] == guess}
      indices.each {|j| @game_spaces[j] = guess}
      puts "Correct guess! you have #{@TOTAL_CHANCES - 1} guesses left"
    else
      puts "#Incorrect guess, you have #{@TOTAL_CHANCES - 1} guesses left"
    end
    @TOTAL_CHANCES -= 1
    show_progress
  end

  def game_lost
    @TOTAL_CHANCES == 0 && @game_spaces.include?("_")
  end

  def game_won
    @TOTAL_CHANCES >= 0 && !@game_spaces.include?("_")
  end

  def show_progress
    puts "Here is your current hangman game: "
    puts @game_spaces.join(" ")
    puts ""
  end

  def show_guesses_guessed
    puts "You have guessed: #{@guesses_guessed.join('')}"
  end

  def show_outcome
    if game_won
      puts "Yayyy! You won the game"
    else
      puts "BOOOOO you lost, the word was #{@game_word}"
    end
  end

  def play_game
    show_progress
    until game_lost || game_won
      show_guesses_guessed
      guess = get_guess
      process_guess(guess)
      ask_if_want_to_save
    end
    show_outcome
  end

  def ask_if_want_to_save
    puts "do you want to save your progress? (Y/N)"
    save = gets.chomp
    save_game if save == 'Y'
  end

  def save_game
    yaml = YAML::dump(self)
    game_file = File.new("saved_games/saved.yaml", 'w')
    game_file.write(yaml)
  end

  def self.load_game
    game_file = File.new("saved_games/saved.yaml", 'r')
    yaml = game_file.read
    YAML::load(yaml)
  end

end

puts "Welcome to Hangman"
puts "===========================\n"
puts "Would you like to load a game? (Y/N)"
response = gets.chomp
if response == 'Y'
  my_game = Game.load_game
else
  puts "Please enter your name: "
  my_game = Game.new(gets.chomp)
end

my_game.play_game
