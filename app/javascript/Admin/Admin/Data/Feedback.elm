module Admin.Data.Feedback exposing
    ( Feedback
    , FeedbackId
    , FeedbackStatus
    , FeedbackStatusInput
    , feedbackByIdQuery
    , feedbackExtractor
    , requestFeedbacksQuery
    , updateFeedabackStatusMutation
    )

import GraphQL.Request.Builder as GQLBuilder
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var


type alias FeedbackId =
    String


type alias FeedbackStatus =
    String


type alias FeedbackStatusInput =
    { id : String
    , status : String
    }


type alias Feedback =
    { id : FeedbackId
    , name : String
    , message : String
    , status : String
    }


requestFeedbacksQuery :
    GQLBuilder.Document GQLBuilder.Query
        (Maybe (List Feedback))
        { vars
            | status : FeedbackStatus
        }
requestFeedbacksQuery =
    let
        statusVar =
            Var.required "status" .status Var.string
    in
    GQLBuilder.queryDocument <|
        GQLBuilder.extract
            (GQLBuilder.field "feedbacks"
                [ ( "status", Arg.variable statusVar ) ]
                (GQLBuilder.nullable
                    (GQLBuilder.list
                        feedbackExtractor
                    )
                )
            )


feedbackByIdQuery : GQLBuilder.Document GQLBuilder.Query (Maybe Feedback) { vars | id : String }
feedbackByIdQuery =
    let
        idVar =
            Var.required "id" .id Var.string
    in
    GQLBuilder.queryDocument
        (GQLBuilder.extract
            (GQLBuilder.field "feedback"
                [ ( "id", Arg.variable idVar ) ]
                (GQLBuilder.nullable
                    feedbackExtractor
                )
            )
        )


updateFeedabackStatusMutation : GQLBuilder.Document GQLBuilder.Mutation (Maybe Feedback) FeedbackStatusInput
updateFeedabackStatusMutation =
    let
        idVar =
            Var.required "id" .id Var.string

        statusVar =
            Var.required "status" .status Var.string
    in
    GQLBuilder.mutationDocument <|
        GQLBuilder.extract <|
            GQLBuilder.field "updateFeedbackStatus"
                [ ( "input"
                  , Arg.object
                        [ ( "id", Arg.variable idVar )
                        , ( "status", Arg.variable statusVar )
                        ]
                  )
                ]
                (GQLBuilder.extract <|
                    GQLBuilder.field "feedback"
                        []
                        (GQLBuilder.nullable
                            feedbackExtractor
                        )
                )


feedbackExtractor : GQLBuilder.ValueSpec GQLBuilder.NonNull GQLBuilder.ObjectType Feedback vars
feedbackExtractor =
    GQLBuilder.object Feedback
        |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "name" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "message" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "status" [] GQLBuilder.string)
