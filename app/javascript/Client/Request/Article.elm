module Request.Article exposing (..)

import Http
import Task exposing (Task)
import Reader exposing (Reader)
import Request.Helpers exposing (..)
import Data.Article exposing (..)
import Data.ContactUs exposing (FeedbackForm)
import Data.Common exposing (..)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder


requestArticleList : Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error (List ArticleSummary))
requestArticleList =
    Reader.Reader
        (\( env, apiKey ) ->
            GQLClient.customSendQuery (requestOptions env apiKey) <|
                GQLBuilder.request {} articlesQuery
        )


requestSuggestedArticles : Context -> Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error (List ArticleSummary))
requestSuggestedArticles context =
    Reader.Reader
        (\( env, apiKey ) ->
            GQLClient.customSendQuery (requestOptions env apiKey) <|
                GQLBuilder.request { url = contextToMaybe context } suggestedArticledQuery
        )


requestArticle : ArticleId -> Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error Article)
requestArticle articleId =
    Reader.Reader
        (\( env, apiKey ) ->
            GQLClient.customSendQuery (requestOptions env apiKey) <|
                GQLBuilder.request { articleId = articleId } articleQuery
        )


requestSearchArticles :
    String
    -> Reader ( NodeEnv, ApiKey ) (Task Http.Error ArticleListResponse)
requestSearchArticles searchTerm =
    Reader.Reader
        (\( env, apiKey ) ->
            Http.toTask (httpGet apiKey Request.Helpers.NoContext (apiUrl env "articles/search") [ ( "query", searchTerm ) ] decodeArticles)
        )


requestUpvoteMutation :
    ArticleId
    -> Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error ArticleSummary)
requestUpvoteMutation articleId =
    Reader.Reader
        (\( env, apiKey ) ->
            GQLClient.customSendMutation (requestOptions env apiKey) <|
                GQLBuilder.request { articleId = articleId } upvoteMutation
        )


requestDownvoteMutation :
    ArticleId
    -> Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error ArticleSummary)
requestDownvoteMutation articleId =
    Reader.Reader
        (\( env, apiKey ) ->
            GQLClient.customSendMutation (requestOptions env apiKey) <|
                GQLBuilder.request { articleId = articleId } downvoteMutation
        )


requestAddFeedbackMutation :
    FeedbackForm
    -> Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error (Maybe (List GQLError)))
requestAddFeedbackMutation feedbackFrom =
    Debug.log (toString feedbackFrom)
        Reader.Reader
        (\( env, apiKey ) ->
            GQLClient.sendMutation (graphqlUrl env) <|
                GQLBuilder.request feedbackFrom addFeedbackMutation
        )
