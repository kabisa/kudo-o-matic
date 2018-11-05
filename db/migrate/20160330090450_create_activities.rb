# frozen_string_literal: true

class CreateActivities < ActiveRecord::Migration[4.2]
  def change
    create_table :activities do |t|
      t.string :name, limit: 60
      t.integer :amount

      t.timestamps null: false
    end
  end
end
