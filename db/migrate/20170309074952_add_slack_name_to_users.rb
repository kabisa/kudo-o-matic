# frozen_string_literal: true

class AddSlackNameToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :slack_name, :string
  end
end
