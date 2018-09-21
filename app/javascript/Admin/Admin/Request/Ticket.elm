module Admin.Request.Ticket exposing
    ( addNotesAndCommentToTicket
    , assignTicketToAgent
    , deleteTicketRequest
    , requestAgents
    , requestTicketById
    , requestTickets
    , updateTicket
    )

import Admin.Data.Ticket exposing (..)
import Admin.Request.Helper exposing (..)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder
import Reader exposing (Reader)
import Task exposing (Task)


requestTickets : Reader ( NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe (List Ticket)))
requestTickets =
    Reader.Reader
        (\( nodeEnv, apiKey, appUrl ) ->
            GQLClient.customSendQuery (requestOptions nodeEnv apiKey appUrl) <|
                GQLBuilder.request {} requestTicketQuery
        )


requestAgents : Reader ( NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe (List Agent)))
requestAgents =
    Reader.Reader
        (\( env, apiKey, appUrl ) ->
            GQLClient.customSendQuery (requestOptions env apiKey appUrl) <|
                GQLBuilder.request {} requestAgentsQuery
        )


requestTicketById : TicketId -> Reader ( NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe Ticket))
requestTicketById ticketId =
    Reader.Reader
        (\( nodeEnv, apiKey, appUrl ) ->
            GQLClient.customSendQuery (requestOptions nodeEnv apiKey appUrl) <|
                GQLBuilder.request { id = ticketId } requestTicketByIdQuery
        )


updateTicket : TicketInput -> Reader ( NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe Ticket))
updateTicket ticketInput =
    Reader.Reader
        (\( nodeEnv, apiKey, appUrl ) ->
            GQLClient.customSendMutation (requestOptions nodeEnv apiKey appUrl) <|
                GQLBuilder.request ticketInput updateTicketMutation
        )


deleteTicketRequest : TicketId -> Reader ( NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe Ticket))
deleteTicketRequest ticketId =
    Reader.Reader
        (\( nodeEnv, apiKey, appUrl ) ->
            GQLClient.customSendMutation (requestOptions nodeEnv apiKey appUrl) <|
                GQLBuilder.request { id = ticketId } deleteTicketMutation
        )


addNotesAndCommentToTicket :
    TicketNoteComment
    -> Reader ( NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe Ticket))
addNotesAndCommentToTicket ticket =
    Reader.Reader
        (\( nodeEnv, apiKey, appUrl ) ->
            GQLClient.customSendMutation (requestOptions nodeEnv apiKey appUrl) <|
                GQLBuilder.request ticket addTicketNotesAndCommentMutation
        )


assignTicketToAgent :
    TicketAgentInput
    -> Reader ( NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe Ticket))
assignTicketToAgent ticketAgentInput =
    Reader.Reader
        (\( nodeEnv, apiKey, appUrl ) ->
            GQLClient.customSendMutation (requestOptions nodeEnv apiKey appUrl) <|
                GQLBuilder.request ticketAgentInput assignTicketToAgentMutation
        )
