# frozen_string_literal: true

class Goal < ApplicationRecord
  acts_as_votable

  validates :name, presence: true
  validates :amount, presence: true

  belongs_to :kudos_meter

  def self.previous(team)
    where(kudos_meter: team.active_kudos_meter).where.not(achieved_on: nil).order("amount DESC").first
  end

  def self.next(team)
    where(kudos_meter: team.active_kudos_meter).where(achieved_on: nil).order("amount ASC").first
  end

  def achieved?
    achieved_on.present?
  end

  def achieve!
    touch(:achieved_on)
  end
end
