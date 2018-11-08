# frozen_string_literal: true

class RenameBalanceToKudoMeters < ActiveRecord::Migration[5.2]
  def change
    rename_table :balances, :kudo_meters
  end
end
