# frozen_string_literal: true

class KudosMeter < ApplicationRecord
  validates :name, presence: true

  belongs_to :team
  has_many :posts, dependent: :destroy
  has_many :goals, dependent: :destroy

  def self.likes(kudos_meter)
    Post.joins("INNER JOIN votes on votes.votable_id = posts.id and votable_type='Post'").where("kudos_meter_id=#{kudos_meter.id}").count
  end

  def amount
    Post.where(kudos_meter: self).sum(:amount) + KudosMeter.likes(self)
  end
end
