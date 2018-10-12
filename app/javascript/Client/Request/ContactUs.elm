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
    -> Reader ( AppUrl, ApiKey ) (Task GQLClient.Error (Maybe (List GQLError)))
requestAddTicketMutation feedbackFrom =
    Reader.Reader
        (\( appUrl, apiKey ) ->
            GQLClient.customSendMutation (requestOptions appUrl apiKey) <|
                GQLBuilder.request feedbackFrom addTicketMutation
        )
