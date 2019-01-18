# frozen_string_literal: true

class RenameKudosMeterReference < ActiveRecord::Migration[5.2]
  def change
    rename_column :goals, :balance_id, :kudos_meter_id
  end
end
