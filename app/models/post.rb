# frozen_string_literal: true

# == Schema Information
#
# Table name: posts
#
#  id                           :integer          not null, primary key
#  sender_id                    :integer
#  receiver_id                  :integer
#  activity_id                  :integer
#  balance_id                   :integer
#  amount                       :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  image_file_name              :string
#  image_content_type           :string
#  image_file_size              :integer
#  image_updated_at             :datetime
#  slack_reaction_created_at    :string
#  slack_post_updated_at :string
#  slack_kudos_left_on_creation :integer
#  team_id                      :integer
#


class Post < ApplicationRecord
  validates :sender, presence: true
  validates :receivers, presence: true
  validates :message, presence: true, length: { minimum: 4, maximum: 140 }
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 1000 }

  # also creates a second image file with a maximum width and/or height of 800 pixels with its aspect ratio preserved
  # #TODO upgrade to Rails ActiveStorage
  # has_attached_file :image, styles: { thumb: "600x600" }
  # validates_attachment :image, content_type: { content_type: ["image/jpeg", "image/gif", "image/png"] }
  # validates_with AttachmentSizeValidator, attributes: :image, less_than: 10.megabytes
  # process_in_background :image

  attr_accessor :image_delete_checkbox

  acts_as_votable
  belongs_to :balance
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
    15.minutes.ago
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

  def sender_name
    if sender
      sender.name
    else
      "Deleted"
    end
  end

  def self.all_for_user(user)
    Post.where(sender: user).or(Post.where(receiver: user)).or(
      Post.where(receiver: User.where(name: ENV["COMPANY_USER"]))
    ).order("created_at desc")
  end

  def self.all_for_user_in_team(user, team)
    result = []

    user.sent_posts.where(team: team).each { |post| result << post }
    user.received_posts.where(team: team).each { |post| result << post }

    result
  end

  def self.send_by_user(user, team)
    user.sent_posts.where(team: team)
  end

  def self.received_by_user(user, team)
    user.received_posts.where(team: team)
  end

  def self.last_of_team(team)
    Post.where(team_id: team.id).last
  end

  def liked_by_user?(user)
    votes.find_by_voter_id(user.id).present?
  end
end
