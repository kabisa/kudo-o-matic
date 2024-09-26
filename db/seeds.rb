# frozen_string_literal: true

require "database_cleaner"

DatabaseCleaner.clean_with(:truncation)

teams = ['Kabisa', 'Kiota', 'Dovetail']

teams.each do |team|
  Team.create(name: team)
end

users = ['Ariejan', 'Stefan', 'Marijn', 'Egon', 'Ralph', 'Guido']


users.each do |user|
  user = User.create(
    name: user,
    email: "#{user.downcase}@example.com",
    password: 'password',
    password_confirmation: 'password'
  )
  team_invite = TeamInvite.create(email: user.email, team: Team.first)
  team_invite.accept
  TeamMember.where(user: user).first.update(role: 'admin')
end

##################
###
### Team Kabisa
###
##################

20.times do
  kudos = [1, 5, 10, 20, 50]
  Guideline.create(
    name: Faker::Lorem.sentence(4),
    kudos: kudos.sample,
    team: Team.first
  )
end

25.times do
  sender = Team.first.users.order('RANDOM()').first

  post = Post.create(
    sender: sender,
    receivers: Team.first.users.limit(rand(1..2)).order("RANDOM()").where.not(company_user: true),
    message: Faker::Lorem.sentence(3),
    amount: rand(1..10),
    kudos_meter: Team.first.active_kudos_meter,
    team: Team.first
  )
  if rand(1..5) == 1
    User.all.each do |user|
      post.liked_by user
    end
  end
end

##################
###
### Team Kiota
###
##################

10.times do
  kudos = [1, 5, 10, 20, 50]
  Guideline.create(
    name: Faker::Lorem.sentence(4),
    kudos: kudos.sample,
    team: Team.second
  )

end

users.last(3).each do |user|
  team_invite = TeamInvite.create(email: "#{user.downcase}@example.com", team: Team.second)
  team_invite.accept
end

TeamMember.last.update(role: 'admin')

users.first(3).each do |user|
  TeamInvite.create(email: "#{user.downcase}@example.com", team: Team.second)
end

5.times do
  sender = Team.second.users.order('RANDOM()').first

  post = Post.create(
    sender: sender,
    receivers: Team.second.users.limit(rand(1..2)).order("RANDOM()").where.not(company_user: true),
    message: Faker::Lorem.sentence(3),
    amount: rand(1..10),
    kudos_meter: Team.second.active_kudos_meter,
    team: Team.second
  )
  if rand(1..5) == 1
    Team.second.users.each do |user|
      post.liked_by user
    end
  end
end

##################
###
### Team Dovetail
###
##################

15.times do
  kudos = [1, 5, 10, 20, 50]
  Guideline.create(
    name: Faker::Lorem.sentence(4),
    kudos: kudos.sample,
    team: Team.third
  )
end

users.last(3).each do |user|
  team_invite = TeamInvite.create(email: "#{user.downcase}@example.com", team: Team.third)
  team_invite.accept
end

TeamMember.last.update(role: 'admin')

users.first(3).each do |user|
  TeamInvite.create(email: "#{user.downcase}@example.com", team: Team.third)
end

5.times do
  sender = Team.third.users.order('RANDOM()').first

  post = Post.create(
    sender: sender,
    receivers: Team.third.users.limit(rand(1..2)).order("RANDOM()").where.not(company_user: true),
    message: Faker::Lorem.sentence(3),
    amount: rand(1..10),
    kudos_meter: Team.third.active_kudos_meter,
    team: Team.third
  )

  if rand(1..5) == 1
    Team.third.users.each do |user|
      post.liked_by user
    end
  end
end
