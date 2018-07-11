module Request.Article exposing (..)

import Http
import Task exposing (Task)
import Reader exposing (Reader)
import Request.Helpers exposing (apiUrl, graphqlUrl, httpGet, ApiKey, Context, NodeEnv)
import Data.Article exposing (ArticleId, Article, ArticleListResponse, ArticleSummary, decodeArticles, decodeArticleResponse, articleQuery, upvoteMutation, downvoteMutation)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder


requestArticleList : Reader ( NodeEnv, ApiKey, Context ) (Task Http.Error ArticleListResponse)
requestArticleList =
    Reader.Reader (\( env, apiKey, context ) -> Http.toTask (httpGet apiKey context (apiUrl env "article") [] decodeArticles))



-- Reader.Reader (\( env, apiKey, context ) -> Http.toTask (httpGet apiKey context ("https://www.mocky.io/v2/5b1a4ce93300001000fb1362") [] decodeArticles))


requestArticle : ArticleId -> Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error Article)
requestArticle articleId =
    Reader.Reader
        (\( env, apiKey ) ->
            GQLClient.sendQuery (graphqlUrl env) <|
                GQLBuilder.request { articleId = articleId } articleQuery
        )


requestSearchArticles : Reader ( NodeEnv, ApiKey, String ) (Task Http.Error ArticleListResponse)
requestSearchArticles =
    Reader.Reader
        (\( env, apiKey, searchTerm ) ->
            Http.toTask (httpGet apiKey Request.Helpers.NoContext (apiUrl env "articles/search") [ ( "query", searchTerm ) ] decodeArticles)
        )



-- GRAPHQL


requestUpvoteMutation : ArticleId -> Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error ArticleSummary)
requestUpvoteMutation articleId =
    Reader.Reader
        (\( env, apiKey ) ->
            GQLClient.sendMutation (graphqlUrl env) <|
                GQLBuilder.request { articleId = articleId } upvoteMutation
        )


requestDownvoteMutation : ArticleId -> Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error ArticleSummary)
requestDownvoteMutation articleId =
    Reader.Reader
        (\( env, apiKey ) ->
            GQLClient.sendMutation (graphqlUrl env) <|
                GQLBuilder.request { articleId = articleId } downvoteMutation
        )
