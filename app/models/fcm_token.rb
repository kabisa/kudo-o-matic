# frozen_string_literal: true

class FcmToken < ApplicationRecord
  validates :token, uniqueness: true

  belongs_to :user
end
