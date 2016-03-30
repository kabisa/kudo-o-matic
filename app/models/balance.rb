class Balance < ActiveRecord::Base

  has_many :transactions

  def self.current
    where(current: true).order("created_at DESC").first
  end

  def self.current_amount
    current.amount
  end

  def last_transaction
    transactions.order("created_at DESC").first
  end

end
