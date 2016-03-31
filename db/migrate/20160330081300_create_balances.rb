class CreateBalances < ActiveRecord::Migration
  def change
    create_table :balances do |t|
      t.string :name
      t.integer :amount

      t.boolean :current, default: false

      t.timestamps null: false
    end
  end
end
