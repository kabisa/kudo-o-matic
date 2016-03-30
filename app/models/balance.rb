class Balance < ActiveRecord::Base

  def self.current
    where(current: true).order("created_at DESC").first
  end

  def self.current_amount
    current.amount
  end

end
