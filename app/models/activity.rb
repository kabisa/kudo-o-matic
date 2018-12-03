# frozen_string_literal: true

class Activity < ApplicationRecord
  has_many :posts
  acts_as_votable
  def to_s
    name
  end
end
