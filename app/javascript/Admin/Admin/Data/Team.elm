module Admin.Data.Team exposing
    ( Team
    , TeamMember
    , TeamResponse
    , UserId
    , createTeamMemberMutation
    , removeUserFromOrganization
    , requestTeamQuery
    , teamMemberExtractor
    )

import Admin.Data.Common exposing (..)
import GraphQL.Request.Builder as GQLBuilder
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var


type alias UserId =
    String


type alias Team =
    { id : UserId
    , name : String
    , email : String
    }


type alias TeamMember =
    { firstName : String
    , lastName : String
    , email : String
    }


type alias TeamResponse =
    { user : Maybe Team
    , errors : Maybe (List Error)
    }


requestTeamQuery : GQLBuilder.Document GQLBuilder.Query (Maybe (List Team)) vars
requestTeamQuery =
    GQLBuilder.queryDocument <|
        GQLBuilder.extract
            (GQLBuilder.field "users"
                []
                (GQLBuilder.nullable
                    (GQLBuilder.list
                        teamMemberExtractor
                    )
                )
            )


createTeamMemberMutation : GQLBuilder.Document GQLBuilder.Mutation TeamResponse TeamMember
createTeamMemberMutation =
    let
        emailVar =
            Var.required "email" .email Var.string

        firstNameVar =
            Var.required "firstName" .firstName Var.string

        lastNameVar =
            Var.required "lastName" .lastName Var.string
    in
    GQLBuilder.mutationDocument <|
        GQLBuilder.extract <|
            GQLBuilder.field "assign_user_to_organization"
                [ ( "input"
                  , Arg.object
                        [ ( "email", Arg.variable emailVar )
                        , ( "firstName", Arg.variable firstNameVar )
                        , ( "lastName", Arg.variable lastNameVar )
                        ]
                  )
                ]
                teamResponseObject


teamMemberExtractor : GQLBuilder.ValueSpec GQLBuilder.NonNull GQLBuilder.ObjectType Team vars
teamMemberExtractor =
    GQLBuilder.object Team
        |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "name" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "email" [] GQLBuilder.string)


removeUserFromOrganization : GQLBuilder.Document GQLBuilder.Mutation (Maybe (List Team)) { a | email : String }
removeUserFromOrganization =
    let
        emailVar =
            Var.required "email" .email Var.string
    in
    GQLBuilder.mutationDocument <|
        GQLBuilder.extract <|
            GQLBuilder.field "dismissUser"
                [ ( "input"
                  , Arg.object
                        [ ( "email", Arg.variable emailVar ) ]
                  )
                ]
                (GQLBuilder.extract
                    (GQLBuilder.field "team"
                        []
                        (GQLBuilder.nullable
                            (GQLBuilder.list
                                teamMemberExtractor
                            )
                        )
                    )
                )


teamResponseObject : GQLBuilder.ValueSpec GQLBuilder.NonNull GQLBuilder.ObjectType TeamResponse vars
teamResponseObject =
    GQLBuilder.object TeamResponse
        |> GQLBuilder.with
            (GQLBuilder.field "user"
                []
                (GQLBuilder.nullable teamMemberExtractor)
            )
        |> GQLBuilder.with errorsField
