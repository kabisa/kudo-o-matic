# frozen_string_literal: true

require "database_cleaner"

DatabaseCleaner.clean_with(:truncation)

balance = Balance.create(name: "Balance Name", current: true)
team = Team.create(name: Faker::Company.name)

15.times do
  name = Faker::Name.unique.first_name
  user = User.create(
    name: name,
    email: "#{name}@example.com",
    password: "password",
    password_confirmation: "password"
  )
  team.add_member(user)
end



100.times do
  sender = User.offset(rand(User.count)).first

  Post.create(
    sender: sender,
    receivers: User.limit(rand(1..5)).order("RANDOM()").where.not(id: sender.id),
    message: Faker::Lorem.sentence(3),
    amount: rand(1..500),
    balance: balance,
    team: team
  )
end
