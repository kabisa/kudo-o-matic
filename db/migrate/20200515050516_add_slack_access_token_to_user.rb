class AddSlackAccessTokenToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :slack_access_token, :string
    remove_column :users, :slack_registration_token
  end
end
