
module Util
  class ErrorBuilder
    def self.build_errors(context, errors)
      errors.map do |attr, message|
        message = "#{attr}: #{message}"
        context.add_error(GraphQL::ExecutionError.new(message, extensions: { code: 'INPUT_ERROR', attribute: attr }))
      end
      return
    end
  end
end