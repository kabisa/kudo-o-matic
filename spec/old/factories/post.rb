# frozen_string_literal: true

FactoryBot.define do
  factory :post do
    sender { }
    receivers { [] }
    message { Faker::Lorem.sentence(3) }
    amount { rand(1..500) }
    balance { }

    trait :image do
      image { File.new(Rails.root + "spec/fixtures/images/rails.png") }
    end
  end
end
