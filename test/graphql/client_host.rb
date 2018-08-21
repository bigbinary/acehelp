# frozen_string_literal: true

require "graphlient"

module AceHelp
  FaradayConnection = Proc.new do |client|
    client.http do |h|
      h.connection do |c|
        c.use Faraday::Adapter::Rack, Rails.application
      end
    end
  end

  Client = ::Graphlient::Client.new(Rails.application.secrets[:graphql_host],
    headers: {
      "api-key": Rails.application.secrets[:api_key]
    }, &FaradayConnection)

  CustomClient = Proc.new { |api_key|
    ::Graphlient::Client.new(Rails.application.secrets[:graphql_host],
                             headers: {
                               "api-key": api_key
                             }, &FaradayConnection)
  }

  ClientLoggedIn = -> (user) do
    context_options = {
        headers: {
            "api-key": Rails.application.secrets[:api_key]
        }.merge(user.create_new_auth_token)
    }
    ::Graphlient::Client.new(Rails.application.secrets[:graphql_host],
                             context_options, &FaradayConnection)
  end
end
