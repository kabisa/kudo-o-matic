# frozen_string_literal: true

FactoryBot.define do
  factory :post do
    message { "the message why I give kudos" }
    amount { rand(1..500) }
  end
end
