# frozen_string_literal: true

class AddActivityToPost < ActiveRecord::Migration[5.2]
  def self.up
    add_column :posts, :message, :string
    execute "UPDATE posts p SET message = a.name FROM activities a WHERE p.id = p.activity_id;"
    remove_column :activities, :name
  end

  def self.down
    add_column :activities, :name, :string
    execute "UPDATE activities a SET name = p.message FROM posts p WHERE p.activity_id = p.id;"
    remove_column :posts, :message
  end
end
