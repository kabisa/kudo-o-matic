class Goal < ActiveRecord::Base

  def self.previous
    where.not(achieved_on: nil).order("amount DESC").first
  end

  def self.next
    where(achieved_on: nil).order("amount ASC").first
  end

end
