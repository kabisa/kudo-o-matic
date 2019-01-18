# frozen_string_literal: true

class CreateGoals < ActiveRecord::Migration[4.2]
  def change
    create_table :goals do |t|
      t.string :name, limit: 32
      t.integer :amount
      t.date :achieved_on, default: nil

      t.timestamps null: false
    end
  end
end
