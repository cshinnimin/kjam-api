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

  # Returns an array of standings hashes sorted by the rules:
  # 1) pts desc
  # 2) w desc
  # 3) if tied and exactly two teams share pts & w, use head-to-head aggregate total (greater total wins)
  # 4) goal differential (gf - ga) desc
  def self.standings
    teams = Team.select(:id, :name, :colour, :gp, :w, :l, :t, :gf, :ga, :hw, :pts).map do |t|
      {
        id: t.id,
        team_name: t.name,
        team_color: t.colour,
        gp: t.gp.to_i,
        w: t.w.to_i,
        l: t.l.to_i,
        t: t.t.to_i,
        gf: t.gf.to_i,
        ga: t.ga.to_i,
        hw: t.hw.to_i,
        pts: t.pts.to_i
      }
    end

    # tie group counts for pts & w
    tie_counts = Hash.new(0)
    teams.each { |s| tie_counts[[s[:pts], s[:w]]] += 1 }

    # cache head-to-head aggregates between two teams
    h2h_cache = {}
    compute_h2h = lambda do |a_id, b_id|
      key = [a_id, b_id].sort.join("-")
      return h2h_cache[key] if h2h_cache.key?(key)

      a_total = 0
      b_total = 0

      Game.where(complete: true).where(home_id: [a_id, b_id], away_id: [a_id, b_id]).find_each do |g|
        home_total = g.home_score_half_1.to_i + g.home_score_half_2.to_i
        away_total = g.away_score_half_1.to_i + g.away_score_half_2.to_i

        if g.home_id == a_id && g.away_id == b_id
          a_total += home_total
          b_total += away_total
        elsif g.home_id == b_id && g.away_id == a_id
          a_total += away_total
          b_total += home_total
        end
      end

      h2h_cache[key] = [a_total, b_total]
      h2h_cache[key]
    end

    sorted = teams.sort do |a, b|
      # pts desc
      c = b[:pts] <=> a[:pts]
      next c unless c == 0

      # wins desc
      c = b[:w] <=> a[:w]
      next c unless c == 0

      # if exactly two teams are tied on pts & w, use head-to-head aggregate
      if tie_counts[[a[:pts], a[:w]]] == 2
        a_h2h, b_h2h = compute_h2h.call(a[:id], b[:id])
        if a_h2h != b_h2h
          c = b_h2h <=> a_h2h
          next c
        end
      end

      # goal differential desc
      adiff = a[:gf].to_i - a[:ga].to_i
      bdiff = b[:gf].to_i - b[:ga].to_i
      bdiff <=> adiff
    end

    # return only the requested keys (exclude internal id)
    sorted.map do |s|
      {
        team_name: s[:team_name],
        team_color: s[:team_color],
        gp: s[:gp],
        w: s[:w],
        l: s[:l],
        t: s[:t],
        gf: s[:gf],
        ga: s[:ga],
        hw: s[:hw],
        pts: s[:pts]
      }
    end
  end
end
