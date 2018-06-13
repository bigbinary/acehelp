# frozen_string_literal: true

class Resolvers::CategoriesSearch < GraphQL::Function
  type !types[Types::CategoryType]

  def call(_, _, ctx)
    Category.all
  end
end
