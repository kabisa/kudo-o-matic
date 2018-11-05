# frozen_string_literal: true

FactoryBot.define do
  factory :user, aliases: [:sender, :receiver]  do
    name { Faker::Name.first_name }
    email { "#{Faker::Name.unique.first_name}@example.com" }
    password { "password" }
    password_confirmation { "password" }
  end
end
