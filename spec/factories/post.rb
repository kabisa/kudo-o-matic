# frozen_string_literal: true

FactoryBot.define do
  factory :post do
    sender { }
    receivers { [] }
    message { Faker::Lorem.sentence(3) }
    amount { rand(1..500) }
  end
end
