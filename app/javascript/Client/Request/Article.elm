module Request.Article exposing
    ( requestAddFeedbackMutation
    , requestArticle
    , requestArticleList
    , requestDownvoteMutation
    , requestSearchArticles
    , requestSuggestedArticles
    , requestUpvoteMutation
    )

import Data.Article exposing (..)
import Data.Common exposing (..)
import Data.ContactUs exposing (FeedbackForm)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder
import Reader exposing (Reader)
import Request.Helpers exposing (..)
import Task exposing (Task)


requestArticleList : Reader ( AppUrl, ApiKey ) (Task GQLClient.Error (List ArticleSummary))
requestArticleList =
    Reader.Reader
        (\( appUrl, apiKey ) ->
            GQLClient.customSendQuery (requestOptions appUrl apiKey) <|
                GQLBuilder.request {} articlesQuery
        )


requestSuggestedArticles : Context -> Reader ( AppUrl, ApiKey ) (Task GQLClient.Error (List ArticleSummary))
requestSuggestedArticles context =
    Reader.Reader
        (\( appUrl, apiKey ) ->
            GQLClient.customSendQuery (requestOptions appUrl apiKey) <|
                GQLBuilder.request { url = contextToMaybe context, status = Just "active" } suggestedArticledQuery
        )


requestArticle : ArticleId -> Reader ( AppUrl, ApiKey ) (Task GQLClient.Error Article)
requestArticle articleId =
    Reader.Reader
        (\( appUrl, apiKey ) ->
            GQLClient.customSendQuery (requestOptions appUrl apiKey) <|
                GQLBuilder.request { articleId = articleId } articleQuery
        )


requestSearchArticles : String -> Reader ( AppUrl, ApiKey ) (Task GQLClient.Error (List ArticleSummary))
requestSearchArticles searchString =
    Reader.Reader
        (\( appUrl, apiKey ) ->
            GQLClient.customSendQuery (requestOptions appUrl apiKey) <|
                GQLBuilder.request { searchString = searchString } searchArticlesQuery
        )


requestUpvoteMutation :
    ArticleId
    -> Reader ( AppUrl, ApiKey ) (Task GQLClient.Error ArticleSummary)
requestUpvoteMutation articleId =
    Reader.Reader
        (\( appUrl, apiKey ) ->
            GQLClient.customSendMutation (requestOptions appUrl apiKey) <|
                GQLBuilder.request { articleId = articleId } upvoteMutation
        )


requestDownvoteMutation :
    ArticleId
    -> Reader ( AppUrl, ApiKey ) (Task GQLClient.Error ArticleSummary)
requestDownvoteMutation articleId =
    Reader.Reader
        (\( appUrl, apiKey ) ->
            GQLClient.customSendMutation (requestOptions appUrl apiKey) <|
                GQLBuilder.request { articleId = articleId } downvoteMutation
        )


requestAddFeedbackMutation :
    FeedbackForm
    -> Reader ( AppUrl, ApiKey ) (Task GQLClient.Error (Maybe (List GQLError)))
requestAddFeedbackMutation feedbackFrom =
    Reader.Reader
        (\( appUrl, apiKey ) ->
            GQLClient.sendMutation (graphqlUrl appUrl) <|
                GQLBuilder.request feedbackFrom addFeedbackMutation
        )
