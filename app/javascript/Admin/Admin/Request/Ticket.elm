module Admin.Request.Ticket exposing (..)

import Admin.Request.Helper exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)
import Admin.Data.Ticket exposing (..)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder
import Admin.Data.Session exposing (Token)


requestTickets : Reader ( Token, NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe (List Ticket)))
requestTickets =
    Reader.Reader
        (\( tokens, nodeEnv, apiKey, appUrl ) ->
            GQLClient.customSendQuery (requestOptionsWithToken (Just tokens) nodeEnv apiKey appUrl) <|
                GQLBuilder.request {} requestTicketQuery
        )


requestAgents : Reader ( Token, NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe (List Agent)))
requestAgents =
    Reader.Reader
        (\( tokens, env, apiKey, appUrl ) ->
            GQLClient.customSendQuery (requestOptionsWithToken (Just tokens) env apiKey appUrl) <|
                GQLBuilder.request {} requestAgentsQuery
        )


requestTicketById : TicketId -> Reader ( Token, NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe Ticket))
requestTicketById ticketId =
    Reader.Reader
        (\( tokens, nodeEnv, apiKey, appUrl ) ->
            GQLClient.customSendQuery (requestOptionsWithToken (Just tokens) nodeEnv apiKey appUrl) <|
                (GQLBuilder.request { id = ticketId } requestTicketByIdQuery)
        )


updateTicket : TicketInput -> Reader ( Token, NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe Ticket))
updateTicket ticketInput =
    Reader.Reader
        (\( tokens, nodeEnv, apiKey, appUrl ) ->
            (GQLClient.customSendMutation (requestOptionsWithToken (Just tokens) nodeEnv apiKey appUrl) <|
                GQLBuilder.request ticketInput updateTicketMutation
            )
        )


deleteTicketRequest : TicketId -> Reader ( Token, NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe Ticket))
deleteTicketRequest ticketId =
    Reader.Reader
        (\( tokens, nodeEnv, apiKey, appUrl ) ->
            (GQLClient.customSendMutation (requestOptionsWithToken (Just tokens) nodeEnv apiKey appUrl) <|
                GQLBuilder.request { id = ticketId } deleteTicketMutation
            )
        )


addNotesAndCommentToTicket : TicketNoteComment -> Reader ( Token, NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe Ticket))
addNotesAndCommentToTicket ticket =
    Reader.Reader
        (\( tokens, nodeEnv, apiKey, appUrl ) ->
            (GQLClient.customSendMutation (requestOptionsWithToken (Just tokens) nodeEnv apiKey appUrl) <|
                GQLBuilder.request ticket addTicketNotesAndCommentMutation
            )
        )


assignTicketToAgent : TicketAgentInput -> Reader ( Token, NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe Ticket))
assignTicketToAgent ticketAgentInput =
    Reader.Reader
        (\( tokens, nodeEnv, apiKey, appUrl ) ->
            (GQLClient.customSendMutation (requestOptionsWithToken (Just tokens) nodeEnv apiKey appUrl) <|
                GQLBuilder.request ticketAgentInput assignTicketToAgentMutation
            )
        )
