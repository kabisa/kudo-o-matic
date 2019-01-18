# frozen_string_literal: true

class RenameKudosMeterReferenceInPost < ActiveRecord::Migration[5.2]
  def change
    rename_column :posts, :balance_id, :kudos_meter_id
  end
end
