class Goal < ActiveRecord::Base

  def self.previous
    where.not(achieved_on: nil).order("target_kudos DESC").first
  end

  def self.next
    where(achieved_on: nil).order("target_kudos ASC").first
  end

end
