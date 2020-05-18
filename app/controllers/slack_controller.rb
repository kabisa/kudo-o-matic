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

  def team_auth_callback
    begin
      SlackService.add_to_workspace(params[:code], params[:team_id])
      redirect_to Settings.slack_team_connect_success_url
    rescue SlackService::InvalidRequest => e
      render json: {text: "That didn't quite work, #{e}"}
    end
  end

  def user_auth_callback
    begin
      SlackService.connect_account(params[:code], params[:user_id])
      redirect_to Settings.slack_user_connect_success_url
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

  def auth_team
    redirect_to SlackService.get_team_oauth_url(params[:team_id]).to_s
  end

  def auth_user
    redirect_to SlackService.get_user_oauth_url(params[:user_id]).to_s
  end

  def reaction

    case params[:type]
    when 'url_verification'
      return render json: {challenge: params[:challenge]}
    when 'event_callback'
      case params[:event][:type]
      when 'reaction_added'
        render status: :ok, json: {ok: true }
        SlackService.reaction_added(params[:team_id], params[:event])
      when 'reaction_removed'
        render status: :ok, json: {ok: true }
        SlackService.reaction_removed(params[:team_id], params[:event])
      else
        return render json: {text: 'unsupported event'}
      end
    else
      render json: {text: 'unsupported event'}
    end

  end
end
