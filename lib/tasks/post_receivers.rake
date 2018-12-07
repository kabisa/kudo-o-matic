namespace :post_receivers do
  desc 'Move null receivers to receivers field'
  task move: :environment do

    Post.all.each do |post|
      next unless post.receivers.empty?

      begin
        # Find users in post message
        receivers = post.message.split('for:')[0].strip.split(/[,&+]/)
        receivers = receivers.map(&:lstrip)

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

          users << user
        end

        # update receivers
        post.update(receivers: users)

        # Update post message
        message = post.message.split('for:')[1].strip
        post.update(message: message)
      rescue
        post.destroy
      end
    end
  end
end