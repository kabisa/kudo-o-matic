# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  name                   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string
#  locked_at              :datetime
#  provider               :string
#  uid                    :string
#  avatar_url             :string
#  slack_name             :string
#  admin                  :boolean          default(FALSE)
#  api_token              :string
#  deactivated_at         :datetime
#  preferences            :json
#  slack_id               :string
#  slack_username         :string
#  restricted             :boolean          default(FALSE)
#  company_user           :boolean          default(FALSE)
#


class User < ApplicationRecord
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true

  after_create :send_welcome_email
  after_update :ensure_an_admin_remains

  acts_as_voter
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  # :database_authenticatable, :registerable,
  # :recoverable, :rememberable, :trackable, :validatable
  devise :omniauthable, :registerable, :confirmable, :database_authenticatable,
         :validatable, :lockable, :recoverable, omniauth_providers: [:slack]

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
    @admin_rights = Hash.new do |h, key|
      h[key] = memberships.find_by_team_id(key).role == 'admin'
    end
    @admin_rights[team.id]
    # TODO: when we implement the functionality to give/revoke admin rights, we need to make sure to invalidate @admin_rights[team.id]
  end

  def open_invites
    TeamInvite.where(email: self.email, accepted_at: nil, declined_at: nil)
  end

  def first_name
    name.split(" ")[0]
  end

  def picture_url
    avatar_url.presence || "/no-picture-icon.jpg"
  end

  def deactivate
    transaction do
      touch(:deactivated_at)
      fcm_tokens.destroy_all
      ensure_an_admin_remains
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

  def ensure_an_admin_remains
    if User.where(admin: true, deactivated_at: nil).count < 1
      raise "Last administrator can't be removed from the system"
    end
  end

  def send_welcome_email
    user = User.find(id)
    UserMailer.welcome_email(user).deliver_now
  end
end
