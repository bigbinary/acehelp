module Admin.Data.Feedback exposing (..)

import GraphQL.Request.Builder as GQLBuilder


type alias FeedbackId =
    String


type alias Feedback =
    { id : FeedbackId
    , name : String
    , message : String
    , status : String
    }


requestFeedbacksQuery : GQLBuilder.Document GQLBuilder.Query (List Feedback) vars
requestFeedbacksQuery =
    GQLBuilder.queryDocument <|
        GQLBuilder.extract
            (GQLBuilder.field "feedbacks"
                []
                (GQLBuilder.list
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
