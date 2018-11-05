# frozen_string_literal: true

# == Schema Information
#
# Table name: activities
#
#  id               :integer          not null, primary key
#  name             :text
#  suggested_amount :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Activity < ApplicationRecord
  has_many :posts
  acts_as_votable
  def to_s
    name
  end
end
