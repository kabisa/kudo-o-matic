class Transaction < ActiveRecord::Base

  belongs_to :balance
  belongs_to :activity
  belongs_to :sender,   class_name: "User", foreign_key: :from_id
  belongs_to :receiver, class_name: "User", foreign_key: :to_id

  delegate :name, to: :sender,   prefix: true
  delegate :name, to: :receiver, prefix: true
  delegate :name, to: :activity, prefix: true

end
