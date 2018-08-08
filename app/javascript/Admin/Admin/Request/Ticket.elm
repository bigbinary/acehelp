module Admin.Request.Ticket exposing (..)

import Admin.Request.Helper exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)
import Admin.Data.Ticket exposing (..)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder


requestTickets : Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error (List Ticket))
requestTickets =
    Reader.Reader
        (\( env, apiKey ) ->
            GQLClient.customSendQuery (requestOptions env apiKey) <|
                GQLBuilder.request {} requestTicketQuery
        )


requestTicketById : TicketId -> Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error TicketEditData)
requestTicketById ticketId =
    Reader.Reader
        (\( env, apiKey ) ->
            GQLClient.customSendQuery (requestOptions env apiKey) <|
                (GQLBuilder.request { id = ticketId } requestTicketByIdQuery)
        )


updateTicket : Reader ( NodeEnv, ApiKey, TicketInput ) (Task GQLClient.Error TicketEditData)
updateTicket =
    Reader.Reader
        (\( nodeEnv, apiKey, ticketInput ) ->
            (GQLClient.customSendMutation (requestOptions nodeEnv apiKey) <|
                GQLBuilder.request ticketInput updateTicketMutation
            )
        )
