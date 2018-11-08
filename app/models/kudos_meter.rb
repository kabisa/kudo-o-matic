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

class KudosMeter < ApplicationRecord
  validates :name, presence: true

  belongs_to :team
  has_many :posts, dependent: :destroy
  has_many :goals, dependent: :destroy

  attr_accessor :make_kudos_meter_active_checkbox

  def last_post
    posts.order("created_at DESC").first
  end

  def self.likes(kudos_meter)
    Post.joins("INNER JOIN votes on votes.votable_id = posts.id and votable_type='Post'").where("kudos_meter_id=#{kudos_meter.id}").count
  end

  def amount
    Post.where(kudos_meter: self).sum(:amount) + KudosMeter.likes(self)
  end

  def self.time_left
    current = Time.new.at_end_of_day
    expire = Time.new.at_end_of_year
    days_left = (expire - current).to_i / (24 * 60 * 60)
    "#{days_left} days left"
  end
end
