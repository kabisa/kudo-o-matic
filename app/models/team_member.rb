# frozen_string_literal: true

class TeamMember < ApplicationRecord
  belongs_to :team
  belongs_to :user

  before_destroy :last_admin_on_destroy?
  before_update :last_admin_on_update?

  def last_admin_on_destroy?
    if role == 'admin' && TeamMember.where(team_id: team_id, role: 'admin').count == 1
      errors.add(:role, "'admin' should be assigned to at least 1 other team member.")
      throw :abort
    end

    TeamInvite.where(email: user.email, team_id: id).delete_all
  end

  def last_admin_on_update?
    if role != 'admin' && TeamMember.where(team_id: team_id, role: 'admin').count == 1 && role_was == 'admin'
      errors.add(:role, "'admin' should be assigned to at least 1 other team member.")
      throw :abort
    end
  end
end
