module Data.Organization exposing (..)

import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var
import GraphQL.Request.Builder as GQLBuilder


type alias Organization =
    { id : String
    , name : String
    }



-- QUERIES


organizationQuery : GQLBuilder.Document GQLBuilder.Query Organization vars
organizationQuery =
    GQLBuilder.queryDocument <|
        GQLBuilder.extract
            (GQLBuilder.field "organizations"
                []
                (GQLBuilder.object Organization
                    |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.string)
                    |> GQLBuilder.with (GQLBuilder.field "name" [] GQLBuilder.string)
                )
            )
