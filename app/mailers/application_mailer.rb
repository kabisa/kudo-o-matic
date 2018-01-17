class ApplicationMailer < ActionMailer::Base
  default from: Rails.env == 'test' || ENV['MAIL_USERNAME'].blank? ? 'example@mail.com' : ENV['MAIL_USERNAME']
  layout 'mailer'

  add_template_helper(TransactionsHelper)
end
