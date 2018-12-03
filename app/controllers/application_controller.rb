# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_raven_context
  around_action :catch_not_found
  helper_method :current_team

  def index; end

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

  def set_raven_context
    Raven.user_context(id: session[:current_user_id]) # or anything else in session
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end

  def catch_not_found
    yield
  rescue ActiveRecord::RecordNotFound
    raise ActiveRecord::RecordNotFound
  end
end
