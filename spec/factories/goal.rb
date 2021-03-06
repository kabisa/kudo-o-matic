# frozen_string_literal: true

# == Schema Information
#
# Table name: goals
#
#  id          :integer          not null, primary key
#  name        :string(32)
#  amount      :integer
#  achieved_on :date
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  kudos_meter_id  :integer
#

FactoryBot.define do
  factory :goal do
    name { "The Goal name" }
    amount { 500 }
    achieved_on { nil }

    trait :achieved do
      achieved_on { 30.days.ago }
    end
  end
end
