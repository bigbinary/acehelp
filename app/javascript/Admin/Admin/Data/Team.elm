module Admin.Data.Team exposing (..)

import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var
import GraphQL.Request.Builder as GQLBuilder


type alias UserId =
    String


type alias TeamMember =
    { id : UserId
    , name : String
    , email : String
    }


type alias TeamMemberInput =
    { firstName : String
    , lastName : String
    , email : String
    }


type alias TeamData =
    { id : UserId
    , email : String
    }


requestTeamQuery : GQLBuilder.Document GQLBuilder.Query (List TeamMember) vars
requestTeamQuery =
    GQLBuilder.queryDocument <|
        GQLBuilder.extract
            (GQLBuilder.field "users"
                []
                (GQLBuilder.list
                    teamMemberExtractor
                )
            )


createTeamMemberMutation : GQLBuilder.Document GQLBuilder.Mutation TeamMember TeamMemberInput
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
                    (GQLBuilder.extract <|
                        GQLBuilder.field "user"
                            []
                            teamMemberExtractor
                    )


teamMemberExtractor : GQLBuilder.ValueSpec GQLBuilder.NonNull GQLBuilder.ObjectType TeamMember vars
teamMemberExtractor =
    (GQLBuilder.object TeamMember
        |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "name" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "email" [] GQLBuilder.string)
    )
