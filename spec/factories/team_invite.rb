FactoryBot.define do
  factory :team_invite do
    email { Faker::Internet.unique.email }
  end

  trait :is_accepted do
    accepted_at { 1.day.ago }
  end

  trait :is_declined do
    declined_at { 1.day.ago }
  end
end