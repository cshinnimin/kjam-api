class CreateTeams < ActiveRecord::Migration[8.1]
  def change
    create_table :teams do |table|
      table.string :name, null: false
      table.string :colour, null: false

      table.integer :gp, default: 0, null: false
      table.integer :w, default: 0, null: false
      table.integer :l, default: 0, null: false
      table.integer :t, default: 0, null: false
      table.integer :hw, default: 0, null: false
      table.integer :gf, default: 0, null: false
      table.integer :ga, default: 0, null: false
      table.integer :pts, default: 0, null: false

      table.timestamps
    end
  end
end
