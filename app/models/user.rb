class User < ActiveRecord::Base

  has_many :sent_transactions, foreign_key: :from_id
  has_many :received_transactions, foreign_key: :to_id

end
