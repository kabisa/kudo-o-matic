require "uri"
require "net/http"

class SlackController < ApplicationController
  protect_from_forgery with: :null_session

  def give_kudos
    begin
      Slack::SlackService.create_post(params[:text], params[:team_id], params[:user_id])
      render json: {text: 'kudos are on the way!'}
    rescue Slack::SlackService::InvalidCommand => e
      return render json: {text: "That didn't quite work, #{e} \n The format is: /kudo @someone @someone.else [amount] for [reason]"}
    end
  end

  def team_auth_callback
    begin
      Slack::SlackService.add_to_workspace(params[:code], params[:team_id])
      redirect_to Settings.slack_team_connect_success_url
    rescue Slack::SlackService::InvalidRequest => e
      render json: {text: "That didn't quite work, #{e}"}
    end
  end

  def user_auth_callback
    begin
      Slack::SlackService.connect_account(params[:code], params[:user_id])
      redirect_to Settings.slack_user_connect_success_url
    rescue Slack::SlackService::InvalidRequest => e
      render json: {text: "That didn't quite work, #{e}"}
    end
  end

  def guidelines
    begin
      payload = Slack::SlackService.list_guidelines(params[:team_id])
      render json: {blocks: payload}
    rescue Slack::SlackService::InvalidCommand => e
      render json: {text: "That didn't quite work, #{e}"}
    end
  end

  def auth_team
    redirect_to Slack::SlackService.get_team_oauth_url(params[:team_id])
  end

  def auth_user
    redirect_to Slack::SlackService.get_user_oauth_url(params[:user_id])
  end

  def event
    case params[:type]
    when 'url_verification'
      return render json: {challenge: params[:challenge]}
    when 'event_callback'
      SlackWorker.perform_async(params[:team_id], params[:event].to_unsafe_h)
      return render json: {ok: true}
    else
      return render json: {ok: true}
    end
  end
end
