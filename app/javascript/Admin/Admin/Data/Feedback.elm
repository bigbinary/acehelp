module Admin.Data.Feedback exposing (..)

import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var
import GraphQL.Request.Builder as GQLBuilder


type alias FeedbackId =
    String


type alias FeedbackStatus =
    String


type alias Feedback =
    { id : FeedbackId
    , name : String
    , message : String
    , status : String
    }


requestFeedbacksQuery : GQLBuilder.Document GQLBuilder.Query (List Feedback) { vars | status : FeedbackStatus }
requestFeedbacksQuery =
    let
        statusVar =
            Var.required "status" .status Var.string
    in
        GQLBuilder.queryDocument <|
            GQLBuilder.extract
                (GQLBuilder.field "feedbacks"
                    [ ( "status", Arg.variable statusVar ) ]
                    (GQLBuilder.list
                        feedbackExtractor
                    )
                )


feedbackByIdQuery : GQLBuilder.Document GQLBuilder.Query Feedback { vars | id : String }
feedbackByIdQuery =
    let
        idVar =
            Var.required "id" .id Var.string
    in
        GQLBuilder.queryDocument
            (GQLBuilder.extract
                (GQLBuilder.field "feedback"
                    [ ( "id", Arg.variable idVar ) ]
                    feedbackExtractor
                )
            )


feedbackExtractor : GQLBuilder.ValueSpec GQLBuilder.NonNull GQLBuilder.ObjectType Feedback vars
feedbackExtractor =
    (GQLBuilder.object Feedback
        |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "name" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "message" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "status" [] GQLBuilder.string)
    )
