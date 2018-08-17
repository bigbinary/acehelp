class Trigger < ApplicationRecord

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }


end
