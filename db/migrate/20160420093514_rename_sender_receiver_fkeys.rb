# frozen_string_literal: true

class RenameSenderReceiverFkeys < ActiveRecord::Migration[4.2]
  def change
    rename_column :transactions, :from_id, :sender_id
    rename_column :transactions, :to_id, :receiver_id
  end
end
