module Request.ContactUs exposing (..)

import Http
import Task exposing (Task)
import Reader exposing (Reader)
import Data.ContactUs exposing (..)
import Data.Common exposing (GQLError)
import Request.Helpers exposing (..)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder


requestAddTicketMutation : FeedbackForm -> Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error (Maybe (List GQLError)))
requestAddTicketMutation feedbackFrom =
    Reader.Reader
        (\( env, apiKey ) ->
            GQLClient.sendMutation (graphqlUrl env) <|
                GQLBuilder.request feedbackFrom addTicketMutation
        )
