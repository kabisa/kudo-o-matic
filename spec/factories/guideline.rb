# frozen_string_literal: true

FactoryBot.define do
  factory :guideline do
    name { Faker::Lorem.sentence(4) }
    kudos { [1, 5, 10, 20, 50].sample }
  end
end
