class CreateGames < ActiveRecord::Migration[8.1]
  def change
    create_table :games do |t|
      t.datetime :game_time, null: false, default: -> { "'1970-01-01 00:00:00'" }

      t.references :home, null: false, foreign_key: { to_table: :teams }
      t.references :away, null: false, foreign_key: { to_table: :teams }

      t.integer :home_score_half_1, default: 0, null: false
      t.integer :home_score_half_2, default: 0, null: false
      t.integer :away_score_half_1, default: 0, null: false
      t.integer :away_score_half_2, default: 0, null: false

      t.boolean :complete, default: false, null: false

      t.timestamps
    end
  end
end
