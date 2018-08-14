# frozen_string_literal: true

module Deletable
  extend ActiveSupport::Concern

  included do
    default_scope { where(deleted_at: nil) }
  end

  def soft_delete
    update_attributes(deleted_at: DateTime.now)
  end
end
