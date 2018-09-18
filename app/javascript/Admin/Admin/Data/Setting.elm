module Admin.Data.Setting exposing (..)

import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var
import GraphQL.Request.Builder as GQLBuilder


type alias Setting =
    { baseUrl : String
    , visibility : String
    , organization : String
    }


type alias UpdateSettingInputs =
    { visibility : String
    }


settingObject : GQLBuilder.ValueSpec GQLBuilder.NonNull GQLBuilder.ObjectType Setting vars
settingObject =
    GQLBuilder.object Setting
        |> GQLBuilder.with (GQLBuilder.field "baseUrl" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "visibility" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "organization" [] GQLBuilder.string)


updateSettingMutation : GQLBuilder.Document GQLBuilder.Mutation Setting UpdateSettingInputs
updateSettingMutation =
    let
        visibilityVar =
            Var.required "status" .visibility Var.string
    in
        GQLBuilder.mutationDocument <|
            GQLBuilder.extract
                (GQLBuilder.field "changeVisibilityOfWidget"
                    [ ( "input"
                      , Arg.object
                            [ ( "status", Arg.variable visibilityVar )
                            ]
                      )
                    ]
                    (GQLBuilder.extract <|
                        GQLBuilder.field "settingType"
                            []
                            settingObject
                    )
                )
