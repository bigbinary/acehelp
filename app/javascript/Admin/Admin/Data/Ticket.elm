module Admin.Data.Ticket exposing (..)

import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var
import GraphQL.Request.Builder as GQLBuilder


type alias Ticket =
    { id : String
    , name : String
    , email : String
    , message : String
    }


type alias TicketStatus =
    { key : String
    , value : String
    }


type alias TicketEditData =
    { id : String
    , name : String
    , email : String
    , message : String
    , note : String
    , statuses : List TicketStatus
    }


type alias TicketId =
    String


type alias TicketIdInput =
    { id : String
    }


requestTicketQuery : GQLBuilder.Document GQLBuilder.Query (List Ticket) vars
requestTicketQuery =
    GQLBuilder.queryDocument
        (GQLBuilder.extract
            (GQLBuilder.field "tickets"
                []
                (GQLBuilder.list
                    (GQLBuilder.object Ticket
                        |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.string)
                        |> GQLBuilder.with (GQLBuilder.field "name" [] GQLBuilder.string)
                        |> GQLBuilder.with (GQLBuilder.field "email" [] GQLBuilder.string)
                        |> GQLBuilder.with (GQLBuilder.field "message" [] GQLBuilder.string)
                    )
                )
            )
        )


requestTicketByIdQuery : GQLBuilder.Document GQLBuilder.Query TicketEditData { vars | id : String }
requestTicketByIdQuery =
    let
        idVar =
            Var.required "id" .id Var.string
    in
        GQLBuilder.queryDocument
            (GQLBuilder.extract
                (GQLBuilder.field "ticket"
                    [ ( "id", Arg.variable idVar ) ]
                    (GQLBuilder.object TicketEditData
                        |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.string)
                        |> GQLBuilder.with (GQLBuilder.field "name" [] GQLBuilder.string)
                        |> GQLBuilder.with (GQLBuilder.field "email" [] GQLBuilder.string)
                        |> GQLBuilder.with (GQLBuilder.field "message" [] GQLBuilder.string)
                        |> GQLBuilder.with (GQLBuilder.field "note" [] GQLBuilder.string)
                        |> GQLBuilder.with
                            (GQLBuilder.field "statuses"
                                []
                                (GQLBuilder.list
                                    ticketStatusObject
                                )
                            )
                    )
                )
            )


ticketStatusObject : GQLBuilder.ValueSpec GQLBuilder.NonNull GQLBuilder.ObjectType TicketStatus vars
ticketStatusObject =
    GQLBuilder.object TicketStatus
        |> GQLBuilder.with (GQLBuilder.field "key" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "value" [] GQLBuilder.string)
