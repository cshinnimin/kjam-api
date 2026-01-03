class GamesController < ApplicationController
  def index
    @games = Game.includes(:home, :away).order(:game_time)
  end

  def show
    @game = Game.includes(:home, :away).find(params[:id])
  end
end
