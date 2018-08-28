module Admin.Data.User exposing (..)

import Admin.Data.Organization exposing (..)
import GraphQL.Request.Builder as GQLBuilder


type alias User =
    { id : String
    , email : String
    }


type alias UserWithOrganization =
    { id : String
    , email : String
    , organization : Organization
    }


userObject : GQLBuilder.ValueSpec GQLBuilder.NonNull GQLBuilder.ObjectType User vars
userObject =
    GQLBuilder.object User
        |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "email" [] GQLBuilder.string)


userWithOrganizationObject : GQLBuilder.ValueSpec GQLBuilder.NonNull GQLBuilder.ObjectType UserWithOrganization vars
userWithOrganizationObject =
    GQLBuilder.object UserWithOrganization
        |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "email" [] GQLBuilder.string)
        |> GQLBuilder.with
            (GQLBuilder.field "organization"
                []
                (organizationObject)
            )
