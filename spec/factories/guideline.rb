# frozen_string_literal: true

FactoryBot.define do
  factory :guideline do
    name { "The Guideline name" }
    kudos { [1, 5, 10, 20, 50].sample }
  end
end
