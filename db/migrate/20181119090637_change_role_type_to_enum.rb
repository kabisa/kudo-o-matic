class ChangeRoleTypeToEnum < ActiveRecord::Migration[5.2]
  def up
    execute <<-DDL
      CREATE TYPE team_member_role AS ENUM (
        'member', 'moderator', 'admin'
      );

      ALTER TABLE team_members
      ALTER COLUMN role TYPE team_member_role
      USING CASE role
        WHEN 0 THEN 'member'::team_member_role
        WHEN 1 THEN 'moderator'::team_member_role
        WHEN 2 THEN 'admin'::team_member_role
      END
    DDL
  end

  def down
    execute <<-DDL
      DROP TYPE team_member_role CASCADE;
    DDL
    change_column :team_members, :role, :integer # Previous type
  end
end
