# frozen_string_literal: true

module Types
  class EmailAddress < BaseScalar
    graphql_name "EmailAddress"
    description "A field whose value conforms to the standard internet email address format"

    def self.coerce_input(input_value, context)
      if input_value.match(URI::MailTo::EMAIL_REGEXP).present?
        input_value
      else
        raise GraphQL::CoercionError, "cannot coerce `#{input_value.inspect}` to Email"
      end
    end

    def coerce_result(ruby_value)
      ruby_value.to_s
    end
  end
end

