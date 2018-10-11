# frozen_string_literal: true

class GraphqlExecution::WidgetController < GraphqlExecution::BaseController
  include LoadOrganization
  skip_before_action :verify_authenticity_token
end
