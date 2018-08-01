module Admin.Request.Feedback exposing (..)

import Admin.Request.Helper exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)
import Admin.Data.Feedback exposing (..)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder


requestFeedbacks : Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error (List Feedback))
requestFeedbacks =
    Reader.Reader
        (\( nodeEnv, apiKey ) ->
            (GQLClient.customSendQuery (requestOptions nodeEnv apiKey) <|
                GQLBuilder.request {} requestFeedbacksQuery
            )
        )
