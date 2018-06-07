module Request.Article exposing (..)

import Http
import Data.Article exposing (ArticleId, Article, ArticleSummary, decodeArticles, decodeArticle)


requestArticleList : Http.Request (List ArticleSummary)
requestArticleList =
    Http.get "https://www.mocky.io/v2/5afd46c63200005f00f1ab39" decodeArticles



-- Http.get "http://www.mocky.io/v2/5b06b0362f00004f00c61e7b" decodeArticles
-- Http.get (apiUrl "all") decodeArticles


requestArticle : ArticleId -> Http.Request Article
requestArticle aId =
    Http.get "https://www.mocky.io/v2/5afd46363200005300f1ab36" decodeArticle
