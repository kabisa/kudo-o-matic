class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.string :name, limit: 60
      t.integer :amount

      t.timestamps null: false
    end
  end
end
