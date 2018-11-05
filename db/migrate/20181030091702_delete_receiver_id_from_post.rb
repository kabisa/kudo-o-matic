# frozen_string_literal: true

class DeleteReceiverIdFromPost < ActiveRecord::Migration[5.2]
  def change
    remove_column :posts, :receiver_id
  end
end
