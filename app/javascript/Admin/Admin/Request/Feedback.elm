module Admin.Request.Feedback exposing (..)

import Admin.Request.Helper exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)
import Admin.Data.Feedback exposing (..)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder


requestFeedbacks : FeedbackStatus -> Reader ( NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe (List Feedback)))
requestFeedbacks status =
    Reader.Reader
        (\( nodeEnv, apiKey, appUrl ) ->
            (GQLClient.customSendQuery (requestOptions nodeEnv apiKey appUrl) <|
                GQLBuilder.request { status = status } requestFeedbacksQuery
            )
        )


requestFeedbackById : FeedbackId -> Reader ( NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe Feedback))
requestFeedbackById feedbackId =
    Reader.Reader
        (\( nodeEnv, apiKey, appUrl ) ->
            GQLClient.customSendQuery (requestOptions nodeEnv apiKey appUrl) <|
                (GQLBuilder.request
                    { id = feedbackId }
                    feedbackByIdQuery
                )
        )


requestUpdateFeedbackStatus : FeedbackId -> String -> Reader ( NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe Feedback))
requestUpdateFeedbackStatus feedbackId feedbackStatus =
    Reader.Reader
        (\( nodeEnv, apiKey, appUrl ) ->
            (GQLClient.customSendMutation (requestOptions nodeEnv apiKey appUrl) <|
                GQLBuilder.request { id = feedbackId, status = feedbackStatus } updateFeedabackStatusMutation
            )
        )
