module Admin.Request.Feedback exposing (..)

import Admin.Request.Helper exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)
import Admin.Data.Feedback exposing (..)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder
import Admin.Data.Session exposing (Token)


requestFeedbacks : FeedbackStatus -> Reader ( Token, NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe (List Feedback)))
requestFeedbacks status =
    Reader.Reader
        (\( tokens, nodeEnv, apiKey, appUrl ) ->
            (GQLClient.customSendQuery (requestOptionsWithToken (Just tokens) nodeEnv apiKey appUrl) <|
                GQLBuilder.request { status = status } requestFeedbacksQuery
            )
        )


requestFeedbackById : FeedbackId -> Reader ( Token, NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe Feedback))
requestFeedbackById feedbackId =
    Reader.Reader
        (\( tokens, nodeEnv, apiKey, appUrl ) ->
            GQLClient.customSendQuery (requestOptionsWithToken (Just tokens) nodeEnv apiKey appUrl) <|
                (GQLBuilder.request
                    { id = feedbackId }
                    feedbackByIdQuery
                )
        )


requestUpdateFeedbackStatus : FeedbackId -> String -> Reader ( Token, NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe Feedback))
requestUpdateFeedbackStatus feedbackId feedbackStatus =
    Reader.Reader
        (\( tokens, nodeEnv, apiKey, appUrl ) ->
            (GQLClient.customSendMutation (requestOptionsWithToken (Just tokens) nodeEnv apiKey appUrl) <|
                GQLBuilder.request { id = feedbackId, status = feedbackStatus } updateFeedabackStatusMutation
            )
        )
