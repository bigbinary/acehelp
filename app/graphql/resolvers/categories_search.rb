# frozen_string_literal: true

class Resolvers::CategoriesSearch < GraphQL::Function
  type !types[Types::CategoryType]

  def call(_, _, context)
    Category.all
  end
end
