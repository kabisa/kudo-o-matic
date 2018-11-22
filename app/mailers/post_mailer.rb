# frozen_string_literal: true

class PostMailer < ApplicationMailer
  def self.new_post(post)
    return if Rails.env == "test" || ENV["MAIL_USERNAME"].blank? || post.receiver.nil?

    receiver = post.receiver

    if receiver.email.present? && receiver.post_received_mail && receiver.deactivated_at.nil?
      suppress(Exception) { post_email(receiver, post).deliver_later }
    end

    if receiver.name == ENV["COMPANY_USER"]
      User.where.not(email: "").where.not(email: post.sender.email).where(deactivated_at: nil).each do |user|
        suppress(Exception) { post_email(user, post).deliver_later if user.post_received_mail }
      end
    end
  end

  def post_email(user, post)
    @post = post
    @user = user

    mail(to: user.email, subject: "You just received #{ApplicationController.helpers.number_to_kudos(@post.amount)} from #{@post.sender.name}!")
  end
end
