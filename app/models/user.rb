class User < ActiveRecord::Base
  after_update :ensure_an_admin_remains
  after_destroy :ensure_an_admin_remains

  acts_as_voter

  has_many :sent_transactions, class_name: 'Transaction', foreign_key: :sender_id
  has_many :received_transactions, class_name: 'Transaction', foreign_key: :receiver_id

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  # :database_authenticatable, :registerable,
  # :recoverable, :rememberable, :trackable, :validatable
  devise :omniauthable, :omniauth_providers => [:google_oauth2]

  def self.from_omniauth(access_token)
    data = access_token.info
    return if data['email'].split('@')[1] != ENV.fetch('DEVISE_DOMAIN', 'gmail.com')

    user = User.where(uid: access_token.uid).first_or_create(
        provider: access_token.provider,
        uid: access_token.uid,
        name: data['name'],
        email: data['email'],
        avatar_url: data['image']
    )

    UserMailer.new_user(user)

    user
  end

  def to_s
    name
  end

  def picture_url
    avatar_url || '/no-picture-icon.jpg'
  end

  private

  def ensure_an_admin_remains
    if User.where(admin: true).count < 1
      raise "Last administrator can't be removed from the system"
    end
  end
end
