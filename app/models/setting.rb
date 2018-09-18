# frozen_string_literal: true

class Setting < ApplicationRecord
  belongs_to :organization

  enum visibility: {
    enable: true,
    disable: false
  }
end
