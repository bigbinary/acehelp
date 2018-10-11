module Admin.Data.Setting exposing
    ( Setting
    , SettingsResponse
    , UpdateSettingInputs
    , organizationSettingQuery
    , settingObject
    , settingResponseObject
    , updateBaseUrlMutation
    , updateVisibilityMutation
    )

import Admin.Data.Common exposing (..)
import GraphQL.Request.Builder as GQLBuilder
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var


type alias Setting =
    { base_url : Maybe String
    , visibility : Bool
    , widgetInstalled : Bool
    }


type alias SettingsResponse =
    { setting : Maybe Setting
    , errors : Maybe (List Error)
    }


type alias UpdateSettingInputs =
    { visibility : String
    }


settingObject : GQLBuilder.ValueSpec GQLBuilder.NonNull GQLBuilder.ObjectType Setting vars
settingObject =
    GQLBuilder.object Setting
        |> GQLBuilder.with (GQLBuilder.field "base_url" [] (GQLBuilder.nullable GQLBuilder.string))
        |> GQLBuilder.with (GQLBuilder.field "visibility" [] GQLBuilder.bool)
        |> GQLBuilder.with (GQLBuilder.field "widget_installed" [] GQLBuilder.bool)


settingResponseObject : GQLBuilder.ValueSpec GQLBuilder.NonNull GQLBuilder.ObjectType SettingsResponse vars
settingResponseObject =
    GQLBuilder.object SettingsResponse
        |> GQLBuilder.with
            (GQLBuilder.field "setting"
                []
                (GQLBuilder.nullable settingObject)
            )
        |> GQLBuilder.with errorsField


updateVisibilityMutation : GQLBuilder.Document GQLBuilder.Mutation SettingsResponse UpdateSettingInputs
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
                settingResponseObject
            )


updateBaseUrlMutation : GQLBuilder.Document GQLBuilder.Mutation SettingsResponse UpdateSettingInputs
updateBaseUrlMutation =
    let
        baseUrlVar =
            Var.required "base_url" .visibility Var.string
    in
    GQLBuilder.mutationDocument <|
        GQLBuilder.extract
            (GQLBuilder.field "updateBaseUrlForOrganization"
                [ ( "input"
                  , Arg.object
                        [ ( "base_url", Arg.variable baseUrlVar )
                        ]
                  )
                ]
                settingResponseObject
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
