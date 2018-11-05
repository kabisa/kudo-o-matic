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

  def self.from_omniauth(access_token)
    data = access_token.info

    email_address = data["email"]
    email_domain = extract_email_domain(email_address)
    return if email_domain_not_allowed?(email_domain)

    existing_user = User.exists? uid: access_token.uid

    user = User.where(uid: access_token.uid).first_or_create(
      provider: access_token.provider,
      uid: access_token.uid,
      name: data["name"],
      email: email_address,
      avatar_url: data["image"]
    )

    UserMailer.new_user(user) unless existing_user

    user
  end

  def self.find_by_term(term)
    User.order(:name).where("lower(name) like ?", "#{term}%".downcase)
        .where(deactivated_at: nil).where(restricted: false)
  end

  def member_of?(team)
    memberships.find_by_team_id(team.id).present?
  end

  def member_since(team)
    memberships.find_by_team_id(team.id).created_at
  end

  def admin_of?(team)
    @admin_rights = Hash.new do |h, key|
      h[key] = memberships.find_by_team_id(key)&.admin?
    end
    @admin_rights[team.id]
    # TODO: when we implement the functionality to give/revoke admin rights, we need to make sure to invalidate @admin_rights[team.id]
  end

  def open_invites
    TeamInvite.where(email: self.email, accepted_at: nil, declined_at: nil)
  end

  def all_posts
    Post.all_for_user(self)
  end

  def first_name
    name.split(" ")[0]
  end

  def picture_url
    avatar_url.presence || "/no-picture-icon.jpg"
  end

  def deactivate
    post do
      update(deactivated_at: DateTime.now, api_token: nil)
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

  def slack_id_for_team(team)
    team.membership_of(self).slack_id
  end

  def slack_name_for_team(team)
    team.membership_of(self).slack_name
  end

  def slack_username_for_team(team)
    team.membership_of(self).slack_username
  end

  # overridden Devise method that checks the soft delete timestamp on authentication
  def active_for_authentication?
    super && !deactivated_at
  end

  def to_s
    name
  end

  def to_profile_json
    Jbuilder.new do |user|
      user.name name
      user.avatar_url avatar_url
    end
  end

  private

    def ensure_an_admin_remains
      if User.where(admin: true, deactivated_at: nil).count < 1
        raise "Last administrator can't be removed from the system"
      end
    end

    def self.extract_email_domain(email_address)
      email_address.split("@")[1]
    end

    def self.email_domain_not_allowed?(email_domain)
      email_domain != ENV.fetch("DEVISE_DOMAIN", "gmail.com")
    end

    def self.generate_unique_api_token
      api_token = SecureRandom.urlsafe_base64
      # recursively call this function to ensure that a unique api token is generated
      generate_unique_api_token if User.exists?(api_token: api_token)
      api_token
    end
end
