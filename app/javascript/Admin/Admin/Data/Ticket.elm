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


requestTicketByIdQuery : GQLBuilder.Document GQLBuilder.Query Ticket { vars | id : String }
requestTicketByIdQuery =
    let
        idVar =
            Var.required "id" .id Var.string
    in
        GQLBuilder.queryDocument
            (GQLBuilder.extract
                (GQLBuilder.field "ticket"
                    [ ( "id", Arg.variable idVar )
                    ]
                    (GQLBuilder.object Ticket
                        |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.string)
                        |> GQLBuilder.with (GQLBuilder.field "name" [] GQLBuilder.string)
                        |> GQLBuilder.with (GQLBuilder.field "email" [] GQLBuilder.string)
                        |> GQLBuilder.with (GQLBuilder.field "message" [] GQLBuilder.string)
                    )
                )
            )
