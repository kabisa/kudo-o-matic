class SummaryMailer < ApplicationMailer
  def self.new_summary
    return if Rails.env == 'test' || ENV['MAIL_USERNAME'] == nil

    users = User.where.not(email: '').where(mail_notifications: true)
    users.each do |user|
      summary_email(user).deliver_later
    end
  end

  def summary_email(user)
    @user = user
    @transactions = Transaction.where('created_at >= ?', 1.week.ago).order(amount: :desc).first(7)

    @markdown = Redcarpet::Markdown.new(MdEmoji::Render, :no_intra_emphasis => true)

    attachments.inline['logo.png'] = File.read("#{Rails.root}/app/assets/images/kudo-o-matic-white-mail.png")
    attachments.inline['no-picture-icon.jpg'] = File.read("#{Rails.root}/public/no-picture-icon.jpg")

    mail(to: user.email, subject: 'Weekly ₭udo summary!')
  end
end
