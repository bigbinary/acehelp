module Request.Article exposing (..)

import Http
import Data.Article exposing (Article, ArticleShort, decodeArticles, decodeArticle)

requestArticles : Http.Request (List ArticleShort)
requestArticles =
    Http.get "http://www.mocky.io/v2/5afd46c63200005f00f1ab39" decodeArticles


requestArticle : Int -> Http.Request Article
requestArticle aId =
    Http.get "http://www.mocky.io/v2/5afd46363200005300f1ab36" decodeArticle