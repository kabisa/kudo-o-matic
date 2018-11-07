# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  around_action :catch_not_found
  helper_method :current_team

  def new_session_path(_scope)
    new_user_session_path
  end

  def check_team_membership
    unless current_user.member_of?(current_team)
      render "teams/access_denied", status: 403
    end
  end

  def check_team_member_rights
    redirect_to dashboard_path(team: current_team) unless current_user.admin_of?(current_team)
  end

  def current_team
    @current_team ||= team_by_slug
  end

  protected

    def team_by_slug
      Team.friendly.find(params[:team]) if params[:team]
    end

  private

    def catch_not_found
      yield
    rescue ActiveRecord::RecordNotFound
      raise ActiveRecord::RecordNotFound
    end
end
