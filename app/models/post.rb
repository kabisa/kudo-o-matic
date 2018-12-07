# frozen_string_literal: true

class Post < ApplicationRecord
  validates :sender, presence: true
  validates :receivers, presence: true
  validates :message, presence: true, length: { minimum: 4, maximum: 140 }
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 1000 }
  validates :team, presence: true
  validates :kudos_meter, presence: true
  validates :image, file_content_type: {
      allow: %w[image/jpeg image/png image/gif],
      if: -> { image.attached? }
  }

  has_one_attached :image

  acts_as_votable
  belongs_to :kudos_meter
  belongs_to :team
  belongs_to :activity

  belongs_to :sender, class_name: "User"

  has_many :post_receivers,
           dependent: :destroy
  has_many :receivers,
           through: :post_receivers,
           source: :user

  has_many :votes, foreign_key: "votable_id"

  delegate :name, to: :sender,   prefix: true

  def self.editable_time
    Time.now - Settings.max_edit_and_delete_time
  end

  def kudos_amount
    amount + votes.count
  end

  def likes_amount
    votes.count
  end

  def receiver_name_feed
    result = []
    receivers.each do |receiver|
      result << receiver.name
    end

    if result.count == 2
      result.join(" and ")
    else
      result.join(", ")
    end
  end

  def receiver_image
    avatars = []
    receivers.ids.nil? ? "/kabisa_lizard.png" : receivers.each do |receiver|
      avatars << receiver.picture_url
    end
    avatars.join(", ")
  end
end
