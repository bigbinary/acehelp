module Request.Article exposing (..)

import Http
import Task exposing (Task)
import Reader exposing (Reader)
import Request.Helpers exposing (apiUrl, graphqlUrl, httpGet, ApiKey, Context, NodeEnv)
import Data.Article exposing (ArticleId, ArticleResponse, ArticleListResponse, ArticleSummary, decodeArticles, decodeArticleResponse, upvoteMutation, downvoteMutation)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder


requestArticleList : Reader ( NodeEnv, ApiKey, Context ) (Task Http.Error ArticleListResponse)
requestArticleList =
    Reader.Reader (\( env, apiKey, context ) -> Http.toTask (httpGet apiKey context (apiUrl env "article") [] decodeArticles))



-- Reader.Reader (\( env, apiKey, context ) -> Http.toTask (httpGet apiKey context ("https://www.mocky.io/v2/5b1a4ce93300001000fb1362") [] decodeArticles))


requestArticle : Reader ( NodeEnv, ApiKey, Context, ArticleId ) (Task Http.Error ArticleResponse)
requestArticle =
    Reader.Reader
        (\( env, apiKey, context, articleId ) ->
            Http.toTask
                (httpGet
                    apiKey
                    context
                    (apiUrl env ("article/" ++ (toString articleId)))
                    []
                    decodeArticleResponse
                )
        )


requestSearchArticles : Reader ( NodeEnv, ApiKey, String ) (Task Http.Error ArticleListResponse)
requestSearchArticles =
    Reader.Reader
        (\( env, apiKey, searchTerm ) ->
            Http.toTask (httpGet apiKey Request.Helpers.NoContext (apiUrl env "articles/search") [ ( "query", searchTerm ) ] decodeArticles)
        )



-- GRAPHQL


requestUpvoteMutation : ArticleId -> Reader NodeEnv (Task GQLClient.Error ArticleSummary)
requestUpvoteMutation articleId =
    Reader.Reader
        (\env ->
            GQLClient.sendMutation (graphqlUrl env) <|
                GQLBuilder.request { articleId = articleId } upvoteMutation
        )


requestDownvoteMutation : ArticleId -> Reader NodeEnv (Task GQLClient.Error ArticleSummary)
requestDownvoteMutation articleId =
    Reader.Reader
        (\env ->
            GQLClient.sendMutation (graphqlUrl env) <|
                GQLBuilder.request { articleId = articleId } downvoteMutation
        )
