require "uri"
require "net/http"

class SlackController < ApplicationController
  protect_from_forgery with: :null_session

  include SlackService

  def give_kudos
    begin
      post = create_post(params[:text], params[:team_id], params[:user_id])
    rescue InvalidCommand => e
      return render json: {text: "That didn't quite work, #{e}"}
    end

    if post.save
      send_post_announcement(post)
      render json: {text: 'kudos are on the way!'}
    else
      render json: {text: "That didn't quite work, #{post.errors.full_messages.join(', ')}"}
    end
  end

  def register
    begin
      connect_account(params[:text], params[:user_id])
      render json: {text: 'Account successfully linked!'}
    rescue InvalidCommand => e
      render json: {text: "That didn't quite work, #{e}"}
    end
  end

  def auth_callback
    begin
      add_to_workspace(params[:code], params[:state])
      redirect_to Settings.slack_connect_success_url
    rescue InvalidRequest => e
      render json: {text: "That didn't quite work, #{e}"}
    end
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
