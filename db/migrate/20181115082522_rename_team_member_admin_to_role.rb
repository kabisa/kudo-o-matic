class RenameTeamMemberAdminToRole < ActiveRecord::Migration[5.2]
  def change
    rename_column :team_members, :admin, :role
  end
end
