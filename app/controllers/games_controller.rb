class GamesController < ApplicationController
  def index
    @games = Game.includes(:home, :away).order(:game_time)
  end

  def show
    @game = Game.includes(:home, :away).find(params[:id])
  end

  def increment_home_half1
    modify_home_half1(1)
  end

  def decrement_home_half1
    modify_home_half1(-1)
  end

  def increment_away_half1
    modify_away_half1(1)
  end

  def decrement_away_half1
    modify_away_half1(-1)
  end

  def increment_home_half2
    modify_home_half2(1)
  end

  def decrement_home_half2
    modify_home_half2(-1)
  end

  def increment_away_half2
    modify_away_half2(1)
  end

  def decrement_away_half2
    modify_away_half2(-1)
  end

  def toggle_complete
    game = Game.find(params[:id])
    game.complete = !game.complete
    if game.save
      render json: { complete: game.complete }
    else
      render json: { errors: game.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def modify_home_half1(delta)
    game = Game.find(params[:id])
    game.home_score_half_1 = [0, game.home_score_half_1.to_i + delta].max
    if game.save
      render json: { home_score_half_1: game.home_score_half_1 }
    else
      render json: { errors: game.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def modify_away_half1(delta)
    game = Game.find(params[:id])
    game.away_score_half_1 = [0, game.away_score_half_1.to_i + delta].max
    if game.save
      render json: { away_score_half_1: game.away_score_half_1 }
    else
      render json: { errors: game.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def modify_home_half2(delta)
    game = Game.find(params[:id])
    game.home_score_half_2 = [0, game.home_score_half_2.to_i + delta].max
    if game.save
      render json: { home_score_half_2: game.home_score_half_2 }
    else
      render json: { errors: game.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def modify_away_half2(delta)
    game = Game.find(params[:id])
    game.away_score_half_2 = [0, game.away_score_half_2.to_i + delta].max
    if game.save
      render json: { away_score_half_2: game.away_score_half_2 }
    else
      render json: { errors: game.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
