# frozen_string_literal: true

class ArticleSearchService
  attr_reader :query

  def initialize(query)
    @query = query
  end

  def process
    Article.search(
      query,
        query_options
    )
  end

  def query_options
    {
        fields: ["title^2", "desc"],
        limit: 10,
        load: false,
        operator: "or",
        select: [:id, :title, :desc],
        order: { _score: :desc }
    }
  end
end
