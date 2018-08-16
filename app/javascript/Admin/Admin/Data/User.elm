module Admin.Data.User exposing (..)

import GraphQL.Request.Builder as GQLBuilder


type alias User =
    { id : String
    , email : String
    }


userObject : GQLBuilder.ValueSpec GQLBuilder.NonNull GQLBuilder.ObjectType User vars
userObject =
    GQLBuilder.object User
        |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "email" [] GQLBuilder.string)
