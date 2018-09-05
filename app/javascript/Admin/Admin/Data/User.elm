module Admin.Data.User exposing (..)

import Admin.Data.Organization exposing (..)
import GraphQL.Request.Builder as GQLBuilder


type alias User =
    { id : String
    , email : String
    }

type alias Error =
    { message : String }


type alias UserWithErrors =
    { user : Maybe User
    , errors : Maybe (List Error)
    }

type alias UserWithOrganization =
    { id : String
    , email : String
    , organization : Maybe Organization
    }

userWithErrorObject : GQLBuilder.ValueSpec GQLBuilder.NonNull GQLBuilder.ObjectType UserWithErrors vars
userWithErrorObject =
    GQLBuilder.object UserWithErrors
        |> GQLBuilder.with
            (GQLBuilder.field "user"
                []
                (GQLBuilder.nullable userObject)
            )
        |> GQLBuilder.with
            (GQLBuilder.field "errors"
                []
                (GQLBuilder.nullable
                    (GQLBuilder.list errorObject)
                )
            )

userObject : GQLBuilder.ValueSpec GQLBuilder.NonNull GQLBuilder.ObjectType User vars
userObject =
    GQLBuilder.object User
        |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "email" [] GQLBuilder.string)


errorObject : GQLBuilder.ValueSpec GQLBuilder.NonNull GQLBuilder.ObjectType Error vars
errorObject =
    GQLBuilder.object Error
        |> GQLBuilder.with (GQLBuilder.field "message" [] GQLBuilder.string)


userWithOrganizationObject : GQLBuilder.ValueSpec GQLBuilder.NonNull GQLBuilder.ObjectType UserWithOrganization vars
userWithOrganizationObject =
    GQLBuilder.object UserWithOrganization
        |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "email" [] GQLBuilder.string)
        |> GQLBuilder.with
            (GQLBuilder.field "organization"
                []
                (GQLBuilder.nullable organizationObject)
            )
