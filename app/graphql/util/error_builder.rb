
module Util
  class ErrorBuilder
    def self.build_errors(context, errors)
      errors.map do |attr, message|
        puts attr
        puts message
        message = "#{attr}: #{message}"
        context.add_error(GraphQL::ExecutionError.new(message, extensions: { code: 'INPUT_ERROR', attribute: attr }))
      end
    end
  end
end