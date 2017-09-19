class TransactionMailer < ApplicationMailer
  def self.new_transaction(transaction)
    return if (Rails.env != 'test' && ENV['MAIL_USERNAME'] == nil)
    @user = User.where.not(email:"").where(mail_notifications:true)
    @user.each do |user|
      transaction_email(user, transaction).deliver_later
    end
  end

  def transaction_email(user, transaction)
    @transaction = transaction
    @user = user
    @markdown = Redcarpet::Markdown.new(MdEmoji::Render, :no_intra_emphasis => true)
    mail(to: user.email, subject: 'New Transaction')
  end

  def self.preview_new_transaction(transaction, user)
    transaction_email(user, transaction)
  end
end
