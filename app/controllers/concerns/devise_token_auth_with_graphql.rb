# frozen_string_literal: true

module Concerns
  module DeviseTokenAuthWithGraphql
    extend ActiveSupport::Concern

    included do
      include DeviseTokenAuth::Concerns::SetUserByToken

      skip_after_action :update_auth_header
      after_action :update_auth_header_with_new_tokens
    end

    private
      def update_auth_header_with_new_tokens
        return unless defined?(@resource) && @resource && @resource.valid? && @client_id

        auth_header = {}

        ensure_pristine_resource do
          @resource.with_lock do
            return if @used_auth_by_token && @resource.tokens[@client_id].nil?
            @is_batch_request = is_batch_request?(@resource, @client_id)

            # extend expiration of batch buffer to account for the duration of
            # this request
            if @is_batch_request
              auth_header = @resource.extend_batch_buffer(@token, @client_id)
              auth_header[DeviseTokenAuth.headers_names[:"access-token"]] = " "
              auth_header[DeviseTokenAuth.headers_names[:"expiry"]] = " "
            else
              auth_header = @resource.create_new_auth_token(@client_id)
            end

          end
        end
        response.headers.merge!(auth_header)
      end
  end
end
