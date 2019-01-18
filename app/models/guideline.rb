# frozen_string_literal: true

class Guideline < ApplicationRecord
  validates :name, presence: true, length: { minimum: 4, maximum: 100 }
  validates :kudos, presence: true, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 1000 }

  belongs_to :team
end
