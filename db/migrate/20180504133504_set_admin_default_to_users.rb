# frozen_string_literal: true

class SetAdminDefaultToUsers < ActiveRecord::Migration[5.0]
  def change
    change_column :users, :admin, :boolean, default: false
  end
end
