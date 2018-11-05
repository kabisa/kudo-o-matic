# frozen_string_literal: true

class PostReceiver < ApplicationRecord
  validates_uniqueness_of :user_id, scope: :post_id

  belongs_to :post
  belongs_to :user
end
