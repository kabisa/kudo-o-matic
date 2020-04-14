require "uri"
require "net/http"

class SlackController < ApplicationController
  # protect_from_forgery with: :null_session

  def index
    puts 'Received slack message:'
    puts request.body

    command = params[:text]

    slackUsers = command.scan(/(?=@).*?(?<=\|)/)

    puts slackUsers
    users = []

    slackUsers.each do |slackUser|
      puts slackUser
      slackUser = slackUser.tr('@', "")
      slackUser = slackUser.tr('|', "")

      user = User.where(slack_id: slackUser).take
      users << user
    end

    puts users.length

    if users.length == 0
      render json: {text: "Oops that did not work. Did you forget to mention any users with the '@' symbol? "}
      return
    end

    message = command[/'(.*?)'/m, 1]
    puts message

    if message == nil || message == ""
      render json: {text: 'Oops that did not work. Did you include a message surrounded by \'?'}
      return
    end

    amount = command.split(' ').last

    if amount == nil || amount == ""
      render json: {text: 'Oops that did not work. Did you include an amount?'}
    end

    puts amount

    render json: {text: 'kudos are on the way!'}
  end

  def register
    puts 'Received register message:'
    slack_register_token = params[:text]

    return render json: {text: 'please provide a register token '} unless slack_register_token != ''

    if User.where(:slack_id => params[:user_id]).length > 0
      render json: {text: 'Your account is already linked to kudo-o-matic!'}
    end

    user = User.where(:unlock_token => slack_register_token).take

    if user.slack_id != nil
      render json: {text: 'Your account is already linked to kudo-o-matic!'}
      return
    end

    user.slack_id = params[:user_id]
    user.save

    render json: {text: 'Account successfully linked!'}
  end

  def test
    puts params

    render json: {text: 'Oauth callback successfully received!'}
  end
end
