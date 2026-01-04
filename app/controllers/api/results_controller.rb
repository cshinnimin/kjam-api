module Api
  class ResultsController < ApplicationController
    def index
      games = Game.includes(:home, :away).order(:game_time).map do |g|
        {
          id: g.id,
          time: g.game_time.strftime("%A, %-l:%M %p"),
          home_name: g.home.name,
          away_name: g.away.name,
          home_color: g.home.colour,
          away_color: g.away.colour,
          home_score: g.home_score_half_1.to_i + g.home_score_half_2.to_i,
          away_score: g.away_score_half_1.to_i + g.away_score_half_2.to_i,
          home_score_half_1: g.home_score_half_1.to_i,
          home_score_half_2: g.home_score_half_2.to_i,
          away_score_half_1: g.away_score_half_1.to_i,
          away_score_half_2: g.away_score_half_2.to_i,
          complete: g.complete
        }
      end

      standings = StandingsCalculator.standings

      render json: { standings: standings, games: games }
    end
  end
end
