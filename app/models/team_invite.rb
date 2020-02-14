# frozen_string_literal: true

class TeamInvite < ApplicationRecord
  validates :email, presence: true
  validates :team, presence: true

  belongs_to :team

  before_create :duplicate?

  def complete?
    accepted_at || declined_at ? true : false
  end

  def declined?
    declined_at ? true : false
  end

  def accept
    transaction do
      touch(:accepted_at)
      user = User.find_by_email(email)
      TeamMember.create(team: team, user: user, role: 'member')
    end
  end

  def decline
    touch(:declined_at)
  end

  def self.open
    where(accepted_at: nil).where(declined_at: nil)
  end

  def duplicate?
    invite = TeamInvite.where(email: email, team: team).first

    send_invite and return if invite.nil?
    send_invite and return if invite.declined?
    
    errors.add(:email, "#{invite.email} is already invited")
    throw :abort
  end

  private

  def send_invite
    UserMailer.invite_email(email, team).deliver_later
  end
end
