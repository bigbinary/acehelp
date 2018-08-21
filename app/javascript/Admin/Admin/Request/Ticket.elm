module Admin.Request.Ticket exposing (..)

import Admin.Request.Helper exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)
import Admin.Data.Ticket exposing (..)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder


requestTickets : Reader ( NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (List Ticket))
requestTickets =
    Reader.Reader
        (\( nodeEnv, apiKey, appUrl ) ->
            GQLClient.customSendQuery (requestOptions nodeEnv apiKey appUrl) <|
                GQLBuilder.request {} requestTicketQuery
        )


requestTicketById : TicketId -> Reader ( NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error Ticket)
requestTicketById ticketId =
    Reader.Reader
        (\( nodeEnv, apiKey, appUrl ) ->
            GQLClient.customSendQuery (requestOptions nodeEnv apiKey appUrl) <|
                (GQLBuilder.request { id = ticketId } requestTicketByIdQuery)
        )


updateTicket : TicketInput -> Reader ( NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error Ticket)
updateTicket ticketInput =
    Reader.Reader
        (\( nodeEnv, apiKey, appUrl ) ->
            (GQLClient.customSendMutation (requestOptions nodeEnv apiKey appUrl) <|
                GQLBuilder.request ticketInput updateTicketMutation
            )
        )


deleteTicketRequest : TicketId -> Reader ( NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error Ticket)
deleteTicketRequest ticketId =
    Reader.Reader
        (\( nodeEnv, apiKey, appUrl ) ->
            (GQLClient.customSendMutation (requestOptions nodeEnv apiKey appUrl) <|
                GQLBuilder.request { id = ticketId } deleteTicketMutation
            )
        )


addNotesAndCommentToTicket : TicketNoteComment -> Reader ( NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error Ticket)
addNotesAndCommentToTicket ticket =
    Reader.Reader
        (\( nodeEnv, apiKey, appUrl ) ->
            (GQLClient.customSendMutation (requestOptions nodeEnv apiKey appUrl) <|
                GQLBuilder.request ticket addTicketNotesAndCommentMutation
            )
        )
