require "open-uri"
require "json"

class GamesController < ApplicationController
  def new
    @letters = generate_grid(10)
    @start_time = Time.now.to_i
  end

  def score
    @attempt = params[:word]
    @letters = params[:letters].split
    start_time = params[:start_time].to_i
    end_time = Time.now.to_i

    @result = run_game(@attempt, @letters, start_time, end_time)
  end

  private

  def generate_grid(grid_size)
    alphabet = ("A".."Z").to_a
    Array.new(grid_size) { alphabet.sample }
  end

  def run_game(attempt, grid, start_time, end_time)
    time = end_time - start_time

    grid_copy = grid.dup
    attempt.upcase.chars.each do |letter|
      if grid_copy.include?(letter)
        grid_copy.delete_at(grid_copy.index(letter))
      else
        return { score: 0, message: "Word not in grid", time: time }
      end
    end

    url = "https://dictionary.lewagon.com/#{attempt.downcase}"
    response = URI.open(url).read
    result = JSON.parse(response)

    return { score: 0, message: "Not an english word", time: time } unless result["found"]

    score = attempt.length.to_f / time
    { score: score, message: "Well Done!", time: time }
  end
end
