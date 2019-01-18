# frozen_string_literal: true

class AddCompanyUserToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :company_user, :boolean, default: false
  end
end
