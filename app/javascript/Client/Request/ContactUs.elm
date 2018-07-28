module Request.ContactUs exposing (..)

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
            GQLClient.customSendMutation (requestOptions env apiKey) <|
                GQLBuilder.request feedbackFrom addTicketMutation
        )