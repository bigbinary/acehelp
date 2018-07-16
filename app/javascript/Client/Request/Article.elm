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
    -- Reader.Reader (\( env, apiKey ) -> Http.toTask (httpGet apiKey context (apiUrl env "article") [] decodeArticles))
    Reader.Reader
        (\( env, apiKey ) ->
            GQLClient.sendQuery (graphqlUrl env) <|
                GQLBuilder.request {} articlesQuery
        )



-- Reader.Reader (\( env, apiKey, context ) -> Http.toTask (httpGet apiKey context ("https://www.mocky.io/v2/5b1a4ce93300001000fb1362") [] decodeArticles))


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



-- requestFeedbackMutation : FeedbackForm -> Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error (Maybe (List GQLError)))
-- requestFeedbackMutation feedbackFrom =
--     Reader.Reader
--         (\( env, apiKey ) ->
--             GQLClient.sendMutation (graphqlUrl env) <|
--                 GQLBuilder.request feedbackFrom feedbackMutation
--         )


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
