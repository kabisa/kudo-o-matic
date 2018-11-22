class ChangeTeamMemberAdminColumnToInt < ActiveRecord::Migration[5.2]
  def change
    change_column :team_members, :admin, :integer, :using => 'case when admin then 2 else 0 end'
  end
end
