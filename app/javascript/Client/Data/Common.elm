module Data.Common exposing (..)

import GraphQL.Request.Builder as GQLBuilder


type alias GQLError =
    { message : String }


type alias GQLErrors =
    { errors : List GQLError
    }


errorsExtractor : GQLBuilder.ValueSpec GQLBuilder.NonNull GQLBuilder.ObjectType (Maybe (List GQLError)) vars
errorsExtractor =
    GQLBuilder.extract <|
        GQLBuilder.field "errors"
            []
            (GQLBuilder.nullable
                (GQLBuilder.list
                    (GQLBuilder.object GQLError
                        |> GQLBuilder.with
                            (GQLBuilder.field "message"
                                []
                                GQLBuilder.string
                            )
                    )
                )
            )
