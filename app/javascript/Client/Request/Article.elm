module Request.Article exposing (..)

import Http
import Task exposing (Task)
import Reader exposing (Reader)
import Request.Helpers exposing (apiUrl, httpGet, ApiKey, Context, NodeEnv)
import Data.Article exposing (ArticleId, Article, ArticleSummary, decodeArticles, decodeArticle)


requestArticleList : Reader ( NodeEnv, ApiKey, Context ) (Task Http.Error (List ArticleSummary))
requestArticleList =
    Reader.Reader (\( env, apiKey, context ) -> Http.toTask (httpGet apiKey context (apiUrl env "article") [] decodeArticles))


requestArticle : Reader ( NodeEnv, ApiKey, Context, ArticleId ) (Task Http.Error Article)
requestArticle =
    Reader.Reader (\( env, apiKey, context, articleId ) -> Http.toTask (httpGet apiKey context (apiUrl env ("article/" ++ (toString articleId))) [] decodeArticle))
