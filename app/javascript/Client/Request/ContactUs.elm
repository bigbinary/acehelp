module Request.ContactUs exposing (requestAddTicketMutation)

import Data.Common exposing (GQLError)
import Data.ContactUs exposing (..)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder
import Reader exposing (Reader)
import Request.Helpers exposing (..)
import Task exposing (Task)


requestAddTicketMutation :
    FeedbackForm
    -> Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error (Maybe (List GQLError)))
requestAddTicketMutation feedbackFrom =
    Reader.Reader
        (\( env, apiKey ) ->
            GQLClient.customSendMutation (requestOptions env apiKey) <|
                GQLBuilder.request feedbackFrom addTicketMutation
        )
