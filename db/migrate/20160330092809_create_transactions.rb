class CreateTransactions < ActiveRecord::Migration
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
