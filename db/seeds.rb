# frozen_string_literal: true

require "database_cleaner"

DatabaseCleaner.clean_with(:truncation)

team = Team.create(name: "Kabisa")

admin = User.create(
  name: "Admin Doe",
  email: "admin@example.com",
  password: "password",
  password_confirmation: "password"
)
team.add_member(admin, 'admin')

users = []
['Kabisa', 'Ariejan', 'Egon', 'Stefan', 'Ralph', 'Marijn', 'Guido', 'Managed-Services'].each do |name|
  user = User.create(
    name: name,
    email: "#{name}@example.com",
    password: "password",
    password_confirmation: "password"
  )
  team.add_member(user)
  users << user
end

20.times do
  kudos = [1, 5, 10, 20, 50]
  Guideline.create(
    name: Faker::Lorem.sentence(4),
    kudos: kudos.sample,
    team: team
  )
end

50.times do
  sender = User.offset(rand(User.count)).first

  post = Post.create(
    sender: sender,
    receivers: User.limit(rand(1..5)).order("RANDOM()").where.not(id: sender.id),
    message: Faker::Lorem.sentence(3),
    amount: rand(1..10),
    kudos_meter: team.active_kudos_meter,
    team: team
  )
  if rand(1..5) == 1
    users.each do |user|
      post.liked_by user
    end
  end
end

5.times do
  TeamInvite.create(email: Faker::Internet.unique.email, team: team)
end
