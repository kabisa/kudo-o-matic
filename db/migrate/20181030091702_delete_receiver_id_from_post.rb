# frozen_string_literal: true

class DeleteReceiverIdFromPost < ActiveRecord::Migration[5.2]
  def up
    Post.all.each do |post|
      begin
        user = User.find(post.receiver_id)
      rescue
        next
      end
      post.update_attribute(:receivers, [user])
    end
    remove_column :posts, :receiver_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
