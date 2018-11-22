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
  belongs_to :team

  after_create :send_invite

  def complete?
    accepted_at || declined_at
  end

  def accept
    transaction do
      update_attribute(:accepted_at, Time.now)
    end
    # touch(:accepted_at)
    user = User.find_by_email(email)
    TeamMember.create(team: team, user: user, role: 'member')
  end

  def decline
    transaction do
      touch(:declined_at)
    end
  end

  def self.open
    where(accepted_at: nil).where(declined_at: nil)
  end

  private

    def send_invite
      UserMailer.invite_email(self.email, self.team).deliver_now
    end
end
