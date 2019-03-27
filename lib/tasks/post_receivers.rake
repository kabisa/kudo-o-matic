namespace :post_receivers do
  desc 'Move null receivers to receivers field'
  task move: :environment do

    Post.all.each do |post|
      next unless post.receivers.empty?

      begin
        # Find users in post message
        post_message = post.message.split('for:')
        receivers = post_message[0].strip.split(/[,&+]/).map(&:lstrip)
        message = post_message[1].strip

        # Update post message
        post.update(message: message)

        users = []
        # Create virtual user for each
        receivers.each do |receiver_name|

          find_user = User.where("name LIKE?", receiver_name).first

          if find_user.nil?
            user = User.new(
              name: receiver_name,
              virtual_user: true
            )

            user.save
          else
            user = find_user
          end
          team = post.team
          team.add_member(user)

          users << user
        end

        # update receivers
        post.update(receivers: users)
      rescue
        post.destroy
      end
    end
  end
end