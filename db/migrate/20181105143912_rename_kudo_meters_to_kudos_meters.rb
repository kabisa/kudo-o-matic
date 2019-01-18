# frozen_string_literal: true

class RenameKudoMetersToKudosMeters < ActiveRecord::Migration[5.2]
  def change
    rename_table :kudo_meters, :kudos_meters
  end
end
