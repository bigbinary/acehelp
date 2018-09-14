module Admin.Data.Organization exposing (Organization, OrganizationData, OrganizationId, OrganizationWithError, UserId, createOrganizationMutation, organizationObject, organizationWithErrorsObject)
import Admin.Data.Article exposing (ArticleSummary)
import Admin.Data.Common exposing (..)
import GraphQL.Request.Builder as GQLBuilder
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var
import Json.Decode exposing (..)
import Admin.Data.Common exposing (..)
import Json.Decode.Pipeline as Pipeline exposing (decode, hardcoded, optional, required)

type alias OrganizationId =
    String


type alias UserId =
    String


type alias Organization =
    { id : OrganizationId
    , name : String
    , api_key : String
    }


type alias OrganizationData =
    { name : String
    , email : String
    , userId : String
    }


type alias OrganizationWithError =
    { organization : Maybe Organization
    , errors : Maybe (List Error)
    }


createOrganizationMutation : GQLBuilder.Document GQLBuilder.Mutation OrganizationWithError OrganizationData
createOrganizationMutation =
    let
        nameVar =
            Var.required "name" .name Var.string

        emailVar =
            Var.required "email" .email Var.string

        userIdVar =
            Var.required "user_id" .userId Var.string
    in
        GQLBuilder.mutationDocument <|
            (GQLBuilder.extract
                (GQLBuilder.field "addOrganization"
                    [ ( "input"
                      , Arg.object
                            [ ( "name", Arg.variable nameVar )
                            , ( "email", Arg.variable emailVar )
                            , ( "user_id", Arg.variable userIdVar )
                            ]
                      )
                    ]
                    organizationWithErrorsObject
                )
            )


organizationWithErrorsObject : GQLBuilder.ValueSpec GQLBuilder.NonNull GQLBuilder.ObjectType OrganizationWithError vars
organizationWithErrorsObject =
    GQLBuilder.object OrganizationWithError
        |> GQLBuilder.with
            (GQLBuilder.field "organization"
                []
                (GQLBuilder.nullable organizationObject)
            )
        |> GQLBuilder.with errorsField


organizationObject : GQLBuilder.ValueSpec GQLBuilder.NonNull GQLBuilder.ObjectType Organization vars
organizationObject =
    GQLBuilder.object Organization
        |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "name" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "api_key" [] GQLBuilder.string)
