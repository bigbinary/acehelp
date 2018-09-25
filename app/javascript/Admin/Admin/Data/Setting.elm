module Admin.Data.Setting exposing
    ( Setting
    , UpdateSettingInputs
    , organizationSettingQuery
    , settingObject
    , updateBaseUrlMutation
    , updateVisibilityMutation
    )

import GraphQL.Request.Builder as GQLBuilder
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var


type alias Setting =
    { base_url : Maybe String
    , visibility : Bool
    }


type alias UpdateSettingInputs =
    { visibility : String
    }


settingObject : GQLBuilder.ValueSpec GQLBuilder.NonNull GQLBuilder.ObjectType Setting vars
settingObject =
    GQLBuilder.object Setting
        |> GQLBuilder.with (GQLBuilder.field "base_url" [] (GQLBuilder.nullable GQLBuilder.string))
        |> GQLBuilder.with (GQLBuilder.field "visibility" [] GQLBuilder.bool)


updateVisibilityMutation : GQLBuilder.Document GQLBuilder.Mutation Setting UpdateSettingInputs
updateVisibilityMutation =
    let
        visibilityVar =
            Var.required "visibility" .visibility Var.string
    in
    GQLBuilder.mutationDocument <|
        GQLBuilder.extract
            (GQLBuilder.field "changeVisibilityOfWidget"
                [ ( "input"
                  , Arg.object
                        [ ( "visibility", Arg.variable visibilityVar )
                        ]
                  )
                ]
                (GQLBuilder.extract <|
                    GQLBuilder.field "setting"
                        []
                        settingObject
                )
            )


updateBaseUrlMutation : GQLBuilder.Document GQLBuilder.Mutation Setting UpdateSettingInputs
updateBaseUrlMutation =
    let
        baseUrlVar =
            Var.required "base_url" .visibility Var.string
    in
    GQLBuilder.mutationDocument <|
        GQLBuilder.extract
            (GQLBuilder.field "updateBaseUrl"
                [ ( "input"
                  , Arg.object
                        [ ( "base_url", Arg.variable baseUrlVar )
                        ]
                  )
                ]
                (GQLBuilder.extract <|
                    GQLBuilder.field "setting"
                        []
                        settingObject
                )
            )


organizationSettingQuery : GQLBuilder.Document GQLBuilder.Query Setting vars
organizationSettingQuery =
    GQLBuilder.queryDocument
        (GQLBuilder.extract
            (GQLBuilder.field "setting"
                []
                settingObject
            )
        )
