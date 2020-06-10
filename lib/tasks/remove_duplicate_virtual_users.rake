namespace :remove_duplicate_virtual_users do
  desc 'Remove duplicate users by redirecting all posts to a single user'
  task :remove => :environment do
    puts 'Removing duplicate users'

    Post.all.each do |post|
      next if post.receivers.empty?

      post.receivers.each do |receiver|
        next unless receiver.virtual_user

        similar_users = User.where('name LIKE?', receiver.name)

        next if similar_users.size == 1

        new_user = nil
        similar_users.each do |user|
          new_user = user unless user.virtual_user
        end

        new_user = similar_users.first if new_user.nil?

        similar_user_ids = similar_users.map { |user| user.id }

        post_receivers = PostReceiver.where('user_id IN (?)', similar_user_ids)

        post_receivers.each do |post_receiver|
          post_receiver.user_id = new_user.id
          post_receiver.save
        end

        votes = Vote.where('voter_id IN (?)', similar_user_ids)

        votes.each do |vote|
          vote.voter_id = new_user.id
          vote.save
        end

        similar_user_ids.delete(new_user.id)

        similar_user_ids.each do |user_id|
          TeamMember.where(user_id: user_id).destroy_all
          User.destroy(user_id)
        end
      end
    end
  end
end

