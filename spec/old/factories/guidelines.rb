# frozen_string_literal: true

FactoryBot.define do
  factory :guideline do
    name { "A guideline suggestion" }
    kudos { 10 }
  end
end
