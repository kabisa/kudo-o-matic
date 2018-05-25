class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  def new_session_path(scope)
    new_user_session_path
  end

  def set_team_and_check_membership
    @current_team = Team.find_by_slug!(params[:tenant])
    unless @current_team.member?(current_user)
      render 'teams/access_denied', status: 403
    end
  end

  protected

  # Set custom fields for registration form
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys:
        %i[name email password password_confirmation])
    devise_parameter_sanitizer.permit(:account_update, keys:
        %i[name email password password_confirmation])
  end

end
