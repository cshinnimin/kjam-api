# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_01_03_121000) do
  create_table "games", force: :cascade do |t|
    t.integer "away_id", null: false
    t.integer "away_score_half_1", default: 0, null: false
    t.integer "away_score_half_2", default: 0, null: false
    t.boolean "complete", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "game_time", default: "1970-01-01 00:00:00", null: false
    t.integer "home_id", null: false
    t.integer "home_score_half_1", default: 0, null: false
    t.integer "home_score_half_2", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["away_id"], name: "index_games_on_away_id"
    t.index ["home_id"], name: "index_games_on_home_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "colour", null: false
    t.datetime "created_at", null: false
    t.integer "ga", default: 0, null: false
    t.integer "gf", default: 0, null: false
    t.integer "gp", default: 0, null: false
    t.integer "hw", default: 0, null: false
    t.integer "l", default: 0, null: false
    t.string "name", null: false
    t.integer "pts", default: 0, null: false
    t.integer "t", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "w", default: 0, null: false
  end

  add_foreign_key "games", "teams", column: "away_id"
  add_foreign_key "games", "teams", column: "home_id"
end
