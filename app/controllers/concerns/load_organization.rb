module LoadOrganization

    extend ActiveSupport::Concern

    included do
      before_action :load_organization
    end

    def load_organization
      @organization = Organization.find_by(api_key: request.headers["api-key"])
      render_unauthorized "Unauthorized request" and return unless @organization
    end
end
