require "uri"
require "net/http"

class SlackController < ApplicationController
  protect_from_forgery with: :null_session

  def give_kudos
    begin
      SlackService.create_post(params[:text], params[:team_id], params[:user_id])
      render json: {text: 'kudos are on the way!'}
    rescue SlackService::InvalidCommand => e
      return render json: {text: "That didn't quite work, #{e}"}
    end
  end

  def register
    begin
      SlackService.connect_account(params[:text], params[:user_id])
      render json: {text: 'Account successfully linked!'}
    rescue SlackService::InvalidCommand => e
      render json: {text: "That didn't quite work, #{e}"}
    end
  end

  def auth_callback
    begin
      SlackService.add_to_workspace(params[:code], params[:state])
      redirect_to Settings.slack_connect_success_url
    rescue SlackService::InvalidRequest => e
      render json: {text: "That didn't quite work, #{e}"}
    end
  end

  def guidelines
    begin
      payload = SlackService.list_guidelines(params[:team_id])
      render json: {blocks: payload}
    rescue SlackService::InvalidCommand => e
      render json: {text: "That didn't quite work, #{e}"}
    end
  end

  def auth
    redirect_to SlackService.get_oauth_url(params[:team_id]).to_s
  end

  def reaction

    case params[:type]
    when 'url_verification'
      render json: {challenge: params[:challenge]}
    when 'reaction_added'
      render json: {text: 'somebody liked something!'}
    when 'reaction_removed'
      render json: {text: 'somebody unliked something!'}
    else
      render json: {text: 'unsupported event'}
    end

  end
end
