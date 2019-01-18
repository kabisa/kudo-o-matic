class AddVirtualUserToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :virtual_user, :boolean, null: false, default: false
  end
end
