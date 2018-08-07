module Admin.Data.Team exposing (..)

import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var
import GraphQL.Request.Builder as GQLBuilder


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


requestTeamQuery : GQLBuilder.Document GQLBuilder.Query (List Team) vars
requestTeamQuery =
    GQLBuilder.queryDocument <|
        GQLBuilder.extract
            (GQLBuilder.field "users"
                []
                (GQLBuilder.list
                    teamMemberExtractor
                )
            )


createTeamMemberMutation : GQLBuilder.Document GQLBuilder.Mutation Team TeamMember
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


teamMemberExtractor : GQLBuilder.ValueSpec GQLBuilder.NonNull GQLBuilder.ObjectType Team vars
teamMemberExtractor =
    (GQLBuilder.object Team
        |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "name" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "email" [] GQLBuilder.string)
    )
