module Request.ContactUs exposing (..)

import Http
import Task exposing (Task)
import Reader exposing (Reader)
import Data.ContactUs exposing (RequestMessage, ResponseMessage, getEncodedContact, decodeMessage, addContactMutation)
import Data.Common exposing (GQLError)
import Request.Helpers exposing (..)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder


requestContactUs : Reader ( NodeEnv, ApiKey, RequestMessage ) (Task Http.Error ResponseMessage)
requestContactUs =
    Reader.Reader (\( env, apiKey, body ) -> Http.toTask (httpPost apiKey (apiUrl env "contacts") (Http.jsonBody <| getEncodedContact body) decodeMessage))


requestAddContactMutation : RequestMessage -> Reader NodeEnv (Task GQLClient.Error (Maybe (List GQLError)))
requestAddContactMutation contactPayload =
    Reader.Reader
        (\env ->
            GQLClient.sendMutation (graphqlUrl env) <|
                GQLBuilder.request contactPayload addContactMutation
        )
