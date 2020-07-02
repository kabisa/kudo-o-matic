namespace :slack_tokens do
  desc 'Remove all slack access tokens from users'
  task :remove => :environment do
    puts 'Removing all slack access tokens'

    User.all.find_each do |user|
      user.slack_access_token = nil
      user.slack_id = nil

      user.save
    end
  end
end

