# frozen_string_literal: true

class User < ApplicationRecord
  validates :name, presence: true
  has_secure_token :slack_registration_token

  after_create :send_welcome_email

  acts_as_voter
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  # :database_authenticatable, :registerable,
  # :recoverable, :rememberable, :trackable, :validatable
  devise :async,
         :registerable,
         :confirmable,
         :database_authenticatable,
         :validatable,
         :recoverable


  has_many :sent_posts,
           class_name: "Post",
           foreign_key: "sender_id",
           dependent: :destroy

  has_many :post_receivers,
           dependent: :destroy
  has_many :received_posts,
           through: :post_receivers,
           source: :post


  has_many :memberships, class_name: "TeamMember", foreign_key: :user_id
  has_many :teams, through: :memberships
  has_many :votes, foreign_key: "voter_id"
  has_many :exports, foreign_key: "user_id"
  has_many :fcm_tokens

  typed_store :preferences, coder: PreferencesCoder do |p|
    p.boolean :post_received_mail, default: true
    p.boolean :goal_reached_mail, default: true
    p.boolean :summary_mail, default: true
  end

  def member_of?(team)
    memberships.find_by_team_id(team.id).present?
  end

  def member_since(team)
    memberships.where(team: team).first&.created_at
  end

  def admin_of?(team)
    return unless member_of?(team)

    memberships.find_by_team_id(team.id).role == 'admin'
  end

  def open_invites
    TeamInvite.where(email: self.email, accepted_at: nil, declined_at: nil)
  end

  def first_name
    name.split(" ")[0]
  end

  def picture_url
    return avatar_url if avatar_url.present?

    gravatar = Digest::MD5::hexdigest(email).downcase
    "https://gravatar.com/avatar/#{gravatar}.png?d=#{Settings.gravatar_style}&s=#{Settings.gravatar_size}"
  end

  def deactivate
    transaction do
      touch(:deactivated_at)
      fcm_tokens.destroy_all
    end
  end

  def reactivate
    update(deactivated_at: nil)
  end

  def deactivated?
    !deactivated_at.nil?
  end

  def multiple_teams?
    teams.length > 1
  end

  # overridden Devise method that checks the soft delete timestamp on authentication
  def active_for_authentication?
    super && !deactivated_at
  end

  private

  def email_required?
    return false if virtual_user

    super
  end

  def password_required?
    return false if virtual_user

    super
  end

  def send_welcome_email
    user = User.find(id)
    return if user.email.blank?

    UserMailer.welcome_email(user).deliver_later
  end
end
