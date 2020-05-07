class AddIsActiveToKudosMeters < ActiveRecord::Migration[5.2]
  def change
    add_column :kudos_meters, :is_active, :boolean
  end
end
