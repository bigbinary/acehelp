module Admin.Data.User exposing (..)


type alias User =
    { id : String
    , email : String
    }


userObject : GQLBuilder.ValueSpec GQLBuilder.NotNull GQLBuilder.ObjectType User vars
userObject =
    GQLBuilder.object User
        |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "email" [] GQLBuilder.string)
