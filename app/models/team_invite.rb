# frozen_string_literal: true

# == Schema Information
#
# Table name: team_invites
#
#  id          :integer          not null, primary key
#  team_id     :integer
#  sent_at     :datetime
#  accepted_at :datetime
#  declined_at :datetime
#  email       :string
#

class TeamInvite < ApplicationRecord
  validates :email, presence: true
  validates :team, presence: true

  belongs_to :team

  after_create :duplicate?

  def complete?
    accepted_at || declined_at ? true : false
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

  private

  def duplicate?
    invite_count = TeamInvite.where(email: email, team: team).count
    raise "There is already an invite send to #{email}" if invite_count > 1

    send_invite
  end

  def send_invite
    UserMailer.invite_email(email, team).deliver_now
  end
end
