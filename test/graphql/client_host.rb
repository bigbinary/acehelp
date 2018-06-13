require "graphlient"

module AceHelp
  Client = ::Graphlient::Client.new(Rails.application.secrets[:graphql_host],
    headers: {
      "api-key": Rails.application.secrets[:api_key]
    }) do |client|
      client.http do |h|
        h.connection do |c|
          c.use Faraday::Adapter::Rack, Rails.application
        end
    end
  end
end
