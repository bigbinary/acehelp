desc "Deletes all articles with temporary flag true"
task delete_temporary_articles: [:environment] do

  delete_articles_with_temporary_flag_true

  puts "Article with temporary flag true has been deleted successfully."
end


def delete_articles_with_temporary_flag_true
  temporary_articles = Article.where(temporary: true)
  temporary_articles.destroy_all
end
