# frozen_string_literal: true

class RenameActivityAmountToSuggestedAmount < ActiveRecord::Migration[4.2]
  def change
    rename_column :activities, :amount, :suggested_amount
  end
end
