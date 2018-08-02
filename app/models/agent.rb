# frozen_string_literal: true

class Agent < User

  default_scope { agents }

  has_many :tickets
end
