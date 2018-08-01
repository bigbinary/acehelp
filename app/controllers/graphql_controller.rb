# frozen_string_literal: true

class GraphqlController < ApplicationController

  def execute
    result = AcehelpSchema.execute(query, variables: variables, context: context, operation_name: operation_name)
    render json: result
  rescue => e
    show_error_in_logs(e)
    graphql_error = Utils::ErrorHandler.new.generate_graphql_error_with_root(e.message, path: ["System Exception"])
    render json: graphql_error, status: 500
  end

  private

    def query
      params[:query]
    end

    def variables
      ensure_hash params[:variables]
    end

    def operation_name
      params[:operationName]
    end

    def context
      context_hash = hash_raise_if_no_org
      @organization = find_org
      context_hash[:organization] = @organization if @organization
      context_hash
    end

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

    def render_unauthorized(message)
      render json: Utils::ErrorHandler.new.generate_graphql_error_with_root(message,
                                                                            path: "load_organization",
                                                                            extensions: { code: "UNAUTHORIZED" })
    end

    def show_error_in_logs(e)
      logger.error e.message
      logger.error e.backtrace.join("\n")

      raise e if Rails.env.test?
    end

    def find_org
      api_key = request.headers["api-key"] || params["organization_api_key"]
      Organization.find_by(api_key: api_key)
    end

    def hash_raise_if_no_org
      context_hash = {}
      context_hash.default_proc = Proc.new do |hsh, key|
        if key == :organization
          raise GraphQL::ExecutionError.new("Missing organization key")
        end
      end
      context_hash
    end
end
