# frozen_string_literal: true

class CategorySerializer < ActiveModel::Serializer
  attributes :id, :name

  has_many :articles, only: %i(id title)
end
