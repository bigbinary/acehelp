module Admin.Data.Ticket exposing (..)

import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var
import GraphQL.Request.Builder as GQLBuilder


type alias Ticket =
    { id : String
    , name : String
    , email : String
    , message : String
    , note : String
    , status : String
    , statuses : List TicketStatus
    , comments : List Comment
    , agent : Agent
    }


type alias TicketStatus =
    { key : String
    , value : String
    }


type alias TicketInput =
    { id : TicketId
    , status : String
    }

type alias TicketNoteComment =
    { id : TicketId
    , note : String
    , comment : String
    }

type alias TicketAgentInput =
    { id : TicketId
    , agent_id : String
    }


type alias TicketId =
    String


type alias Comment =
    { ticket_id : String
    , info : String
    }


type alias Agent =
    { id : String
    , name : String
    }


requestTicketQuery : GQLBuilder.Document GQLBuilder.Query (List Ticket) vars
requestTicketQuery =
    GQLBuilder.queryDocument
        (GQLBuilder.extract
            (GQLBuilder.field "tickets"
                []
                (GQLBuilder.list
                    (ticketObject)
                )
            )
        )


requestTicketByIdQuery : GQLBuilder.Document GQLBuilder.Query Ticket { vars | id : String }
requestTicketByIdQuery =
    let
        idVar =
            Var.required "id" .id Var.string
    in
        GQLBuilder.queryDocument
            (GQLBuilder.extract
                (GQLBuilder.field "ticket"
                    [ ( "id", Arg.variable idVar ) ]
                    (ticketObject)
                )
            )


requestAgentsQuery : GQLBuilder.Document GQLBuilder.Query (List Agent) vars
requestAgentsQuery =
    GQLBuilder.queryDocument
        (GQLBuilder.extract
            (GQLBuilder.field "agents"
                []
                (GQLBuilder.list
                    (agentObject)
                )
            )
        )


ticketStatusObject : GQLBuilder.ValueSpec GQLBuilder.NonNull GQLBuilder.ObjectType TicketStatus vars
ticketStatusObject =
    GQLBuilder.object TicketStatus
        |> GQLBuilder.with (GQLBuilder.field "key" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "value" [] GQLBuilder.string)


commentObject : GQLBuilder.ValueSpec GQLBuilder.NonNull GQLBuilder.ObjectType Comment vars
commentObject =
    GQLBuilder.object Comment
        |> GQLBuilder.with (GQLBuilder.field "ticket_id" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "info" [] GQLBuilder.string)

agentObject : GQLBuilder.ValueSpec GQLBuilder.NonNull GQLBuilder.ObjectType Agent vars
agentObject =
    GQLBuilder.object Agent
        |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "name" [] GQLBuilder.string)


deleteTicketMutation : GQLBuilder.Document GQLBuilder.Mutation Ticket { var | id : TicketId }
deleteTicketMutation =
    let
        idVar =
            Var.required "id" .id Var.string
    in
        GQLBuilder.mutationDocument <|
            GQLBuilder.extract <|
                GQLBuilder.field "deleteTicket"
                    [ ( "input"
                      , Arg.object
                            [ ( "id", Arg.variable idVar ) ]
                      )
                    ]
                    (GQLBuilder.extract <|
                        GQLBuilder.field "ticket"
                            []
                            (ticketObject)
                    )


updateTicketMutation : GQLBuilder.Document GQLBuilder.Mutation Ticket TicketInput
updateTicketMutation =
    let
        idVar =
            Var.required "id" .id Var.string

        statusVar =
            Var.required "status" .status Var.string
    in
        GQLBuilder.mutationDocument <|
            GQLBuilder.extract <|
                GQLBuilder.field "changeTicketStatus"
                    [ ( "input"
                      , Arg.object
                            [ ( "status", Arg.variable statusVar )
                            , ( "id", Arg.variable idVar )
                            ]
                      )
                    ]
                    (GQLBuilder.extract <|
                        GQLBuilder.field "ticket"
                            []
                            (ticketObject)
                    )


addTicketNotesAndCommentMutation : GQLBuilder.Document GQLBuilder.Mutation Ticket TicketNoteComment
addTicketNotesAndCommentMutation =
    let
        idVar =
            Var.required "id" .id Var.string

        noteVar =
            Var.required "note" .note Var.string

        commentVar =
            Var.required "comment" .comment Var.string
    in
        GQLBuilder.mutationDocument <|
            GQLBuilder.extract <|
                GQLBuilder.field "updateTicket"
                    [ ( "input"
                      , Arg.object
                            [ ( "comment", Arg.variable commentVar )
                            , ( "note", Arg.variable noteVar )
                            , ( "id", Arg.variable idVar )
                            ]
                      )
                    ]
                    (GQLBuilder.extract <|
                        GQLBuilder.field "ticket"
                            []
                            (ticketObject)
                    )


assignTicketToAgentMutation : GQLBuilder.Document GQLBuilder.Mutation Ticket TicketAgentInput
assignTicketToAgentMutation =
    let
        idVar =
            Var.required "id" .id Var.string

        agentIdVar =
            Var.required "agent_id" .agent_id Var.string
    in
        GQLBuilder.mutationDocument <|
            GQLBuilder.extract <|
                GQLBuilder.field "assignTicketToAgent"
                    [ ( "input"
                      , Arg.object
                            [ ( "agent_id", Arg.variable agentIdVar )
                            , ( "ticket_id", Arg.variable idVar )
                            ]
                      )
                    ]
                    (GQLBuilder.extract <|
                        GQLBuilder.field "ticket"
                            []
                            (ticketObject)
                    )


ticketObject : GQLBuilder.ValueSpec GQLBuilder.NonNull GQLBuilder.ObjectType Ticket vars
ticketObject =
    GQLBuilder.object Ticket
        |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "name" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "email" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "message" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "note" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "status" [] GQLBuilder.string)
        |> GQLBuilder.with
            (GQLBuilder.field "statuses"
                []
                (GQLBuilder.list
                    ticketStatusObject
                )
            )
        |> GQLBuilder.with
            (GQLBuilder.field "comments"
                []
                (GQLBuilder.list
                    commentObject
                )
            )
        |> GQLBuilder.with
            (GQLBuilder.field "agent"
                []
                (agentObject)
            )
