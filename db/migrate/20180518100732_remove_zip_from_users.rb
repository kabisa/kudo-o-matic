# frozen_string_literal: true

class RemoveZipFromUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :exports, :zip
  end
end
