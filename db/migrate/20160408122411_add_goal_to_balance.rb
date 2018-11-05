# frozen_string_literal: true

class AddGoalToBalance < ActiveRecord::Migration[4.2]
  def change
    add_column :goals, :balance_id, :integer
  end
end
