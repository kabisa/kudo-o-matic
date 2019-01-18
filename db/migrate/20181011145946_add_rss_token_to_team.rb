# frozen_string_literal: true

class AddRssTokenToTeam < ActiveRecord::Migration[5.0]
  def change
    add_column :teams, :rss_token, :string
  end
end
