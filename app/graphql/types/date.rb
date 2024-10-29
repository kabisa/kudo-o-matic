# frozen_string_literal: true

module Types
  class Date < Types::BaseScalar
    graphql_name "Date"
    description "An ISO 8601-encoded date"

    def self.coerce_input(value, _context)
      begin
        ::Date.iso8601(value.to_s)
      rescue ArgumentError
        raise GraphQL::CoercionError, "cannot coerce `#{value.inspect}` to Date"
      end
    end

    def self.coerce_result(value, _context)
      value
    end
  end
end