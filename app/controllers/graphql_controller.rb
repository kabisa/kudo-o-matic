# frozen_string_literal: true

class GraphQLController < ApplicationController
  skip_before_action :verify_authenticity_token

  include AuthenticateUser

  def execute
    authenticate!
    variables = ensure_hash(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]
    context = {
      current_user: current_user,
    }
    result = KudoOMaticSchema.execute(query, variables: variables, context: context, operation_name: operation_name)
    render json: result
  rescue InvalidHeader => _e
    response = {:error => 'invalid_request', :error_description => _e}
    render json: response, status: 400
  rescue InvalidToken, TokenExpired => _e
    response = {:error => 'invalid_token', :error_description => _e}
    render json: response, status: 401
  rescue => e
    raise e unless Rails.env.development?
    handle_error_in_development e
  end

  private

    # Handle form data, JSON body, or a blank value
    def ensure_hash(ambiguous_param)
      case ambiguous_param
      when String
        if ambiguous_param.present?
          ensure_hash(JSON.parse(ambiguous_param))
        else
          {}
        end
      when Hash, ActionController::Parameters
        ambiguous_param
      when nil
        {}
      else
        raise ArgumentError, "Unexpected parameter: #{ambiguous_param}"
      end
    end

    def handle_error_in_development(e)
      logger.error e.message
      logger.error e.backtrace.join("\n")

      render json: { error: { message: e.message, backtrace: e.backtrace }, data: {} }, status: 500
    end
end
