# frozen_string_literal: true

module Deletable
  extend ActiveSupport::Concern

  included do
    default_scope { where(deleted_at: nil) }
  end
end
