module Request.Article exposing (..)

import Http
import Task exposing (Task)
import Reader exposing (Reader)
import Request.Helpers exposing (apiUrl, graphqlUrl, httpGet, ApiKey, Context, NodeEnv)
import Data.Article exposing (..)
import Data.Common exposing (..)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder


requestArticleList : Context -> Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error (List ArticleSummary))
requestArticleList context =
    Reader.Reader
        (\( env, apiKey ) ->
            GQLClient.sendQuery (graphqlUrl env) <|
                GQLBuilder.request {} articlesQuery
        )


requestArticle : ArticleId -> Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error Article)
requestArticle articleId =
    Reader.Reader
        (\( env, apiKey ) ->
            GQLClient.sendQuery (graphqlUrl env) <|
                GQLBuilder.request { articleId = articleId } articleQuery
        )


requestSearchArticles : String -> Reader ( NodeEnv, ApiKey ) (Task Http.Error ArticleListResponse)
requestSearchArticles searchTerm =
    Reader.Reader
        (\( env, apiKey ) ->
            Http.toTask (httpGet apiKey Request.Helpers.NoContext (apiUrl env "articles/search") [ ( "query", searchTerm ) ] decodeArticles)
        )


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
