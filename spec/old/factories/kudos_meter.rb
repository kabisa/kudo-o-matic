# frozen_string_literal: true

# == Schema Information
#
# Table name: kudos_meters
#
#  id         :integer          not null, primary key
#  name       :string
#  current    :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  team_id    :integer
#

FactoryBot.define do
  factory :kudos_meter do
    name { "My KudosMeter" }
  end
end
