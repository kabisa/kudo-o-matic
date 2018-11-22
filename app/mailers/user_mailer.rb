# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def invite_email(email, team)
    @team = team

    mail(to: email, subject: "You've been invited to join the Kudos-o-Matic")
  end

  def welcome_email(user)
    return if user.email.blank?
    @user = user

    mail(to: user.email, subject: "Welcome to the ₭udo-o-Matic!")
  end
end
