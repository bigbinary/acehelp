module Admin.Data.Organization exposing (..)

import Json.Decode exposing (..)
import Json.Decode.Pipeline as Pipeline exposing (decode, hardcoded, optional, required)
import Admin.Data.Article exposing (ArticleSummary, decodeArticleSummary)
import GraphQL.Request.Builder as GQLBuilder
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var


type alias OrganizationId =
    String

type alias UserId =
    String

type alias Organization =
    { id : OrganizationId
    , name : String
    }

type alias OrganizationData =
    { name: String
    , email: String
    , userId: String
    }

type alias OrganizationResponse =
    { organization : Organization
    , articles : List ArticleSummary
    }

createOrganizationMutation : GQLBuilder.Document GQLBuilder.Mutation Organization OrganizationData
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
            GQLBuilder.extract
                (GQLBuilder.field "addOrganization"
                    [ ( "input"
                      , Arg.object
                            [ ( "name", Arg.variable nameVar )
                            , ( "email", Arg.variable emailVar )
                            , ( "user_id", Arg.variable userIdVar )
                            ]
                      )
                    ]
                    (GQLBuilder.extract <|
                        GQLBuilder.field "organization"
                            []
                            organizationObject
                    )
                )

organizationObject : GQLBuilder.ValueSpec GQLBuilder.NonNull GQLBuilder.ObjectType Organization vars
organizationObject =
    GQLBuilder.object Organization
        |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "name" [] GQLBuilder.string)


organization : Decoder OrganizationResponse
organization =
    decode OrganizationResponse
        |> required "organization" (organizationDecoder)
        |> required "articles" (list decodeArticleSummary)


organizationDecoder : Decoder Organization
organizationDecoder =
    decode Organization
        |> required "id" string
        |> required "name" string
