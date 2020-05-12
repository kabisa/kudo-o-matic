class AddSlackRegistrationTokenToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :slack_registration_token, :string
    add_index :users, :slack_registration_token, unique: true
  end
end
