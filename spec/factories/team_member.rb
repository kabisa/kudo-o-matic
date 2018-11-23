FactoryBot.define do
  factory :team_member do
    user { User.second }
    team { Team.first }
    role { 'member' }
  end

  trait :is_moderator do
    role { 'moderator' }
  end

  trait :is_admin do
    role { 'admin' }
  end
end