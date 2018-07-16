module Request.ContactUs exposing (..)

import Http
import Task exposing (Task)
import Reader exposing (Reader)
import Data.ContactUs exposing (..)
import Data.Common exposing (GQLError)
import Request.Helpers exposing (..)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder


-- requestContactUs : Reader ( NodeEnv, ApiKey, RequestMessage ) (Task Http.Error ResponseMessage)
-- requestContactUs =
--     Reader.Reader (\( env, apiKey, body ) -> Http.toTask (httpPost apiKey (apiUrl env "contacts") (Http.jsonBody <| getEncodedContact body) decodeMessage))
-- requestAddContactMutation : RequestMessage -> Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error (Maybe (List GQLError)))
-- requestAddContactMutation contactPayload =
--     Reader.Reader
--         (\( env, apiKey ) ->
--             GQLClient.sendMutation (graphqlUrl env) <|
--                 GQLBuilder.request contactPayload addContactMutation
--         )


requestAddTicketMutation : FeedbackForm -> Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error (Maybe (List GQLError)))
requestAddTicketMutation feedbackFrom =
    Reader.Reader
        (\( env, apiKey ) ->
            GQLClient.sendMutation (graphqlUrl env) <|
                GQLBuilder.request feedbackFrom addTicketMutation
        )
