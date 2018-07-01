class ArticleSearchService
  attr_reader :query

  def initialize(query)
    @query = query
  end

  def process
    Article.search(
        query,
        query_filter
    )
  end

  def query_filter
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