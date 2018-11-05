# frozen_string_literal: true

class RenameTransactionsToPosts < ActiveRecord::Migration[5.2]
  def change
    rename_table :transactions, :posts
  end
end
