# frozen_string_literal: true

class AddDeactivatedAtToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :deactivated_at, :datetime
  end
end
