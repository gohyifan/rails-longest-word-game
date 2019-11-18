require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    session[:score] ||= 0
    @letters = generate_grid(9)
  end

  def score
    word = params[:word]
    grid = JSON.parse(params[:letters])
    english_word(word) && no_duplicate_letter(word, grid) && no_foreign_letter(word, grid) ? score = word.length : score = 0
    session[:score] += score
    @result = message_generator(word, grid)
    @score = session[:score]
  end

  private

  def generate_grid(grid_size)
    # TODO: generate random grid of letters
    grid = []
    grid_size.times { grid << ('A'..'Z').to_a.sample(1).join }
    grid
  end

  def english_word(attempt)
    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
    word_checker = open(url).read
    word = JSON.parse(word_checker)
    word['found']
  end

  def no_duplicate_letter(attempt, grid)
    attempt_h = attempt.upcase.split('').frequency
    grid_h = grid.frequency
    attempt_h.all? { |key, value| value <= grid_h[key] }
  end

  def no_foreign_letter(attempt, grid)
    attempt.upcase.split('').all? { |x| grid.include?(x) }
  end

  def message_generator(attempt, grid)
    return "Your attempt is not an English word" unless english_word(attempt)
    return "Your attempt is not in the grid because there are foreign letters" unless no_foreign_letter(attempt, grid)
    return "Your attempt is not in the grid because some letters are overused" unless no_duplicate_letter(attempt, grid)

    "Well Done!"
  end
end

class Array
  def frequency
    Hash.new(0).tap { |counts| each { |v| counts[v] += 1 } }
  end
end
