# frozen_string_literal: true

module Types
  EmailAddress = GraphQL::ScalarType.define do
    name "EmailAddress"
    description "A field whose value conforms to the standard internet email address format"

    coerce_input ->(value, ctx) do
      if value.match(URI::MailTo::EMAIL_REGEXP).present?
        value
      else
        raise GraphQL::CoercionError, "cannot coerce `#{value.inspect}` to Email"
      end
    end

    coerce_result ->(value, ctx) { value }
  end
end

