module Request.ArticleRequest exposing (..)

import Http
import Data.ArticleData exposing (..)


requestArticleList : Http.Request (List ArticleSummary)
requestArticleList =
    Http.get "https://www.mocky.io/v2/5afd46c63200005f00f1ab39" decodeArticles
