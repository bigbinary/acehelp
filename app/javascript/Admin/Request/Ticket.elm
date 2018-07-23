module Request.Ticket exposing (..)

import Request.RequestHelper exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)
import Data.Ticket exposing (..)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder


requestTickets : Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error (List Ticket))
requestTickets =
    Reader.Reader
        (\( env, apiKey ) ->
            GQLClient.sendQuery (graphqlUrl env) <|
                GQLBuilder.request {} requestTicketQuery
        )
