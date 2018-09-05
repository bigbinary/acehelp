# frozen_string_literal: true

# Overrides DeviseTokenAuth::Concerns::SetUserByToken update_auth_header method.
# Devise's update_auth_header method updates the response header with auth_tokens.
# Here we are updating cookies value with new auth tokens.
# It updates cookies for test environment in case of batch request.

module Concerns
  module DeviseTokenAuthentication
    extend ActiveSupport::Concern

    included do
      include DeviseTokenAuth::Concerns::SetUserByToken

      skip_after_action :update_auth_header
      after_action :update_auth_header_with_new_tokens
    end

    private
      def update_auth_header_with_new_tokens
        # cannot save object if model has invalid params
        return unless defined?(@resource) && @resource && @resource.valid? && @client_id
        auth_header = {}
        ensure_pristine_resource do
          @resource.with_lock do
            return if @used_auth_by_token && @resource.tokens[@client_id].nil?
            # Do not return token for batch requests to avoid invalidated
            # tokens returned to the client in case of race conditions.
            # Use a blank string for the header to still be present and
            # being passed in a XHR response in case of
            # 304 Not Modified responses.
            if is_batch_request?(@resource, @client_id)
              auth_header = @resource.extend_batch_buffer(@token, @client_id)
              auth_header[DeviseTokenAuth.headers_names[:"access-token"]] = " "
              auth_header[DeviseTokenAuth.headers_names[:"expiry"]] = " "
              update_cookies_after_every_result(auth_header) if Rails.env.test?
            else
              auth_header = @resource.create_new_auth_token(@client_id)
              update_cookies_after_every_result(auth_header)
            end

          end
        end
      end
  end
end
