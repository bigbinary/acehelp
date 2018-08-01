module Admin.Request.Feedback exposing (..)

import Admin.Request.Helper exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)
import Admin.Data.Feedback exposing (..)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder


requestFeedbacks : Reader ( NodeEnv, ApiKey, FeedbackStatus ) (Task GQLClient.Error (List Feedback))
requestFeedbacks =
    Reader.Reader
        (\( nodeEnv, apiKey, status ) ->
            (GQLClient.customSendQuery (requestOptions nodeEnv apiKey) <|
                GQLBuilder.request { status = status } requestFeedbacksQuery
            )
        )


requestFeedbackById : FeedbackId -> Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error Feedback)
requestFeedbackById feedbackId =
    Reader.Reader
        (\( env, apiKey ) ->
            GQLClient.customSendQuery (requestOptions env apiKey) <|
                (GQLBuilder.request
                    { id = feedbackId }
                    feedbackByIdQuery
                )
        )


requestUpdateFeedbackStatus : FeedbackId -> Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error Feedback)
requestUpdateFeedbackStatus feedbackId =
    Reader.Reader
        (\( nodeEnv, apiKey ) ->
            (GQLClient.customSendMutation (requestOptions nodeEnv apiKey) <|
                GQLBuilder.request { id = feedbackId } updateFeedabackStatusMutation
            )
        )
