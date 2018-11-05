# frozen_string_literal: true

class CreateTransactions < ActiveRecord::Migration[4.2]
  def change
    create_table :transactions do |t|
      t.integer :from_id
      t.integer :to_id
      t.integer :activity_id
      t.integer :balance_id

      t.integer :amount

      t.timestamps null: false
    end
  end
end
