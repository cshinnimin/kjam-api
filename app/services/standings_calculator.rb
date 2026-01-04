class StandingsCalculator
  # Recalculate all team standings from completed games and persist to teams table
  def self.calculate!
    # reset all numeric columns to zero first
    Team.update_all(gp: 0, w: 0, l: 0, t: 0, gf: 0, ga: 0, hw: 0, pts: 0)

    stats = Hash.new do |h, k|
      h[k] = { gp: 0, w: 0, l: 0, t: 0, gf: 0, ga: 0, hw: 0 }
    end

    Game.where(complete: true).includes(:home, :away).find_each do |game|
      home_id = game.home_id
      away_id = game.away_id

      home_h1 = game.home_score_half_1.to_i
      home_h2 = game.home_score_half_2.to_i
      away_h1 = game.away_score_half_1.to_i
      away_h2 = game.away_score_half_2.to_i

      home_total = home_h1 + home_h2
      away_total = away_h1 + away_h2

      # games played
      stats[home_id][:gp] += 1
      stats[away_id][:gp] += 1

      # win / loss / tie by total
      if home_total > away_total
        stats[home_id][:w] += 1
        stats[away_id][:l] += 1
      elsif home_total < away_total
        stats[away_id][:w] += 1
        stats[home_id][:l] += 1
      else
        stats[home_id][:t] += 1
        stats[away_id][:t] += 1
      end

      # goals for / against
      stats[home_id][:gf] += home_total
      stats[home_id][:ga] += away_total

      stats[away_id][:gf] += away_total
      stats[away_id][:ga] += home_total

      # half wins
      if home_h1 > away_h1
        stats[home_id][:hw] += 1
      elsif home_h1 < away_h1
        stats[away_id][:hw] += 1
      end

      if home_h2 > away_h2
        stats[home_id][:hw] += 1
      elsif home_h2 < away_h2
        stats[away_id][:hw] += 1
      end
    end

    # persist stats and compute points: 2 per win, 1 per tie, 1 per half win
    stats.each do |team_id, s|
      pts = (s[:w] * 2) + (s[:t] * 1) + (s[:hw] * 1)
      Team.where(id: team_id).update_all(
        gp: s[:gp], w: s[:w], l: s[:l], t: s[:t], gf: s[:gf], ga: s[:ga], hw: s[:hw], pts: pts
      )
    end
  end
end
