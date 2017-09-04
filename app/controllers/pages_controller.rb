require 'open-uri'

class PagesController < ApplicationController
  def home
  end

  def game
    @grid_size = params[:grid_size]
    @array = []
    @grid_size.to_i.times { @array << ("a".."z").to_a.sample }
    @start_time = Time.now
    @array
  end

  def score
    @end_time = Time.now
    @word = params[:result]
    url = "https://wagon-dictionary.herokuapp.com/#{@word}"
    parsed_result = JSON.parse(open(url).read)
    @time = (DateTime.parse(@end_time.to_s).to_i - DateTime.parse(params[:start_time]).to_i)
    @array = params[:array]
    if parsed_result["found"] == true && in_grid?(@word, @array)
      @score = compute_score(@time, @word)
      @message = "Well done"
    elsif parsed_result["found"] == true
      @score = 0
      @message = "you used a letter that was not in the grid"
    else
      @score = 0
      @message = "this is not an english word"
    end
    @result_hash = add_to_hash(@score, @time, @message)
  end

  def compute_score(time, attempt)
    time > 60.0 ? 0 : attempt.split("").size * (1.0 - time / 60.0)
  end

  def in_grid?(word, grid)
    grid = grid.downcase.chars
    word.chars.each do |letter|
      if grid.include? letter
        grid.delete_at(grid.find_index(letter))
      else
        return false
      end
    end
    return true
  end

  def add_to_hash(score, time, message)
    my_hash = {}
    my_hash[:score] = score
    my_hash[:time] = time
    my_hash[:message] = message
    return my_hash
  end
end


