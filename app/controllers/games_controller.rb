require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = []
    10.times { @letters << ('A'..'Z').to_a.sample }
  end

  def score
    @word = params[:word]
    @letters = params[:letters].split(' ')
    # API Request
    @result = {}
    @result = word_comparison(template_letter_count, guess_letter_count)
    @result = evaluate_parse if @result.size.zero?
  end

  private

  def evaluate_parse
    result = {}
    parsed = api_comparison(@word)
    if parsed['found'] == false
      result = not_english
    else
      result = word_score

    end
    result
  end

  def not_english
    result = {}
    result[:score] = 0
    result[:message] = 'That is not an english word :('
    result
  end

  def word_score
    result = {}
    result[:score] = Math.sqrt(@word.size)**2
    result[:message] = 'Well done friend!'
    result
  end

  def api_comparison(attempt)
    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
    JSON.parse(open(url).read)
  end

  def guess_letter_count
    word_array = @word.upcase.split('')
    word_hash = Hash.new(0)
    word_array.each { |letter| word_hash[letter] += 1 }
    word_hash
  end

  def template_letter_count
    letters_hash = Hash.new(0)
    @letters.each { |letter| letters_hash[letter] += 1 }
    letters_hash
  end

  # Custom message and zero score if a word is not in the grid
  def word_comparison(letters_hash, word_hash)
    result = {}
    word_hash.each do |key, _value|
      if !letters_hash.include?(key) || word_hash[key] > letters_hash[key]
        result[:score] = 0
        result[:message] = 'Your word is not in the grid :('
        return result
      else
        return {}
      end
    end
  end
end
