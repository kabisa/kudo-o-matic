# frozen_string_literal: true

require "auth_token"

module AuthenticateUser
  class TokenExpired < RuntimeError; end
  class InvalidUser < RuntimeError; end
  class InvalidHeader < RuntimeError; end

  extend ActiveSupport::Concern

  included do
    @current_user = nil
  end

  def current_user
    @current_user
  end

  def authenticate!
    if auth_header.blank?
      @current_user = nil
      return true
    end

    raise InvalidHeader.new "Invalid header" unless auth_token.present?
    raise TokenExpired.new "Token expired" if auth_expired?
    raise RuntimeError.new "Other error: #{auth_payload}" unless auth_ok?

    @current_user = User.find_by(id: auth_payload.dig(:ok, :id))

    true
  end

  private

    def auth_header
      @_auth_header ||= request.headers["Authorization"]
    end

    def auth_token
      @_auth_token ||= auth_header.split(" ")[1].tap do |t|
        raise InvalidHeader.new "Missing token" if t.nil?
      end
    end

    def auth_payload
      @_auth_payload ||= AuthToken.new.verify(auth_token)
    end

    def auth_ok?
      !!auth_payload.dig(:ok)
    end

    def auth_expired?
      auth_payload.dig(:error) == :token_expired
    end
end
