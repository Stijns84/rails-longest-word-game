class WordsController < ApplicationController
  def game
    @grid = Array.new(9) { [*"A".."Z"].sample }
    @start_time = Time.now
  end

  def score
    @grid = params[:grid].split("")
    @start_time = params[:start_time].to_datetime
    @end_time = Time.now
    @attempt = params[:attempt]
    @result = run_game(@attempt, @grid, @start_time, @end_time)
  end

  def run_game(attempt, grid, start_time, end_time)
    api_hash = JSON.parse(open("https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key=2f4447ff-068f-4205-8553-d3abd78e9cbe&backTranslation=true&input=#{attempt}").read)

    translation = api_hash["outputs"][0]["output"]
    timediff = end_time - start_time
    message = ""

    score = attempt.length.to_f * 20 - timediff

    if attempt == translation && attempt_check(attempt, grid)
      message = "not an english word"
      score = 0
      translation = nil
    elsif attempt.length > grid.count
      message = "not in the grid"
      score = 0
    elsif !attempt_check(attempt, grid)
      message = "not in the grid"
      score = 0
    else
      message = "well done"
    end

    return { translation: translation, time: timediff, message: message, score: score }
  end

  def attempt_check(attempt, grid)
    attempt.upcase.split("").each do |letter|
      return false if attempt.upcase.count(letter) > grid.count(letter)
    end
    true
  end

end
