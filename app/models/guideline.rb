# frozen_string_literal: true

# == Schema Information
#
# Table name: guidelines
#
#  id         :integer          not null, primary key
#  name       :string
#  kudos      :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  team_id    :integer
#

class Guideline < ApplicationRecord
  validates :name, presence: true, length: { minimum: 4, maximum: 100 }
  validates :kudos, presence: true, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 1000 }

  belongs_to :team
end
