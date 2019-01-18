# frozen_string_literal: true

module Types
  Date = GraphQL::ScalarType.define do
    name "Date"
    description "An ISO 8601-encoded date"

    coerce_input ->(value, ctx) do
      begin
        Date.iso8601(value.to_s)
      rescue ArgumentError
        raise GraphQL::CoercionError, "cannot coerce `#{value.inspect}` to Date"
      end
    end

    coerce_result ->(value, ctx) { value }
  end
end

