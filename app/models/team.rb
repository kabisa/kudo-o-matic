# frozen_string_literal: true

class Team < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged
  after_create :setup_team

  validates :name, presence: true
  validates :slug, presence: true
  validates :logo, file_content_type: {
      allow: %w[image/jpeg image/png],
      if: -> { logo.attached? }
  }

  has_secure_token :rss_token

  has_many :memberships, class_name: "TeamMember", foreign_key: :team_id
  has_many :users, through: :memberships
  has_one :active_kudos_meter, class_name: "KudosMeter"
  has_many :kudos_meters
  has_many :goals, through: :kudos_meters
  has_many :posts
  has_many :guidelines
  has_many :likes, class_name: "Vote"

  has_one_attached :logo

  typed_store :preferences, coder: PreferencesCoder do |p|
    p.string :primary_color, default: nil
  end

  def slug_candidates
    %i[name name_and_sequence]
  end

  def name_and_sequence
    slug = name.parameterize
    sequence = Team.where("slug like ?", "#{slug}%")

    return slug if sequence.empty?

    "#{slug}-#{sequence.count + 1}"
  end

  def add_member(user, role = 'member')
    TeamMember.create(user: user, team: self, role: role)
  end

  def remove_member(user)
    TeamMember.find_by_user_id_and_team_id(user.id, id).delete
  end

  def member?(user)
    TeamMember.find_by_user_id_and_team_id(user.id, id).present?
  end

  def membership_of(user)
    memberships.find_by_user_id(user.id)
  end

  def manageable_members(current_user)
    memberships.joins(:user)
     .where("users.company_user = false")
     .where("users.id != #{current_user.id}")
  end

  def current_goals
    goals.where(kudos_meter: Team.find(id).active_kudos_meter)
  end

  def achieved_goals
    goals.where(kudos_meter: Team.find(id).active_kudos_meter).where.not(achieved_on: nil)
  end

  def real_users
    users.where(company_user: false)
  end

  private

  def setup_team
    kudos_meter = KudosMeter.create(name: "My first kudos_meter", team_id: id)
    Goal.create(name: "First goal", amount: 500, kudos_meter_id: kudos_meter.id)
    Goal.create(name: "Second goal", amount: 1000, kudos_meter_id: kudos_meter.id)
    Goal.create(name: "Third goal", amount: 1500, kudos_meter_id: kudos_meter.id)

    # Create company user
    user = User.new(name: name, company_user: true)
    user.save(validate: false)
    add_member(user)
  end

  # A hacky but necessary fix to keep showing the current Team logo on logo validation errors
  # https://stackoverflow.com/questions/5526589/paperclip-wrong-attachment-url-on-validation-errors#answer-5995636
  def logo_reverted?
    unless errors[:logo_file_size].blank? && errors[:logo_content_type].blank?
      logo.instance_write(:file_name, logo_file_name_was)
      logo.instance_write(:file_size, logo_file_size_was)
      logo.instance_write(:content_type, logo_content_type_was)
    end
  end
end
