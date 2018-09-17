module Request.Article exposing (requestAddFeedbackMutation, requestArticle, requestArticleList, requestDownvoteMutation, requestSearchArticles, requestSuggestedArticles, requestUpvoteMutation)

import Data.Article exposing (..)
import Data.Common exposing (..)
import Data.ContactUs exposing (FeedbackForm)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder
import Reader exposing (Reader)
import Request.Helpers exposing (..)
import Task exposing (Task)


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
                GQLBuilder.request { url = contextToMaybe context, status = Just "active" } suggestedArticledQuery
        )


requestArticle : ArticleId -> Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error Article)
requestArticle articleId =
    Reader.Reader
        (\( env, apiKey ) ->
            GQLClient.customSendQuery (requestOptions env apiKey) <|
                GQLBuilder.request { articleId = articleId } articleQuery
        )


requestSearchArticles : String -> Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error (List ArticleSummary))
requestSearchArticles searchString =
    Reader.Reader
        (\( env, apiKey ) ->
            GQLClient.customSendQuery (requestOptions env apiKey) <|
                GQLBuilder.request { searchString = searchString } searchArticlesQuery
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
    Reader.Reader
        (\( env, apiKey ) ->
            GQLClient.sendMutation (graphqlUrl env) <|
                GQLBuilder.request feedbackFrom addFeedbackMutation
        )
