
module Util
  class ErrorBuilder
    def self.build_errors(context, errors)
      errors.each do |error|
        message = "#{error.attribute}: #{error.message}"
        context.add_error(GraphQL::ExecutionError.new(message, extensions: { code: 'INPUT_ERROR', attribute: error.attribute }))
      end
      return
    end
  end
end