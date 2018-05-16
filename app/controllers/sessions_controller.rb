# frozen_string_literal: true
class SessionsController < Devise::SessionsController
  after_filter :after_login, only: :create

  def after_login
    # TODO: if user is member of multiple teams, redirect to choice page
    # For now take the first membership found
    membership = current_user.memberships.first
    if membership
      session[:current_team] = membership.team_id
    end
  end
end