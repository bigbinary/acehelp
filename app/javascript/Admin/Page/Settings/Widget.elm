module Page.Settings.Widget exposing
    ( Model
    , Msg(..)
    , codeSnippet
    , init
    , initModel
    , update
    , view
    , widgetSettingsView
    )

import Admin.Data.ReaderCmd exposing (..)
import Admin.Data.Setting exposing (..)
import Admin.Request.Helper exposing (ApiKey, AppUrl, NodeEnv, baseUrl)
import Admin.Request.Setting exposing (..)
import GraphQL.Client.Http as GQLClient
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Page.Errors exposing (errorAlertView)
import Reader exposing (Reader)
import Task exposing (Task)



-- Model


type alias Model =
    { code : String
    , isKeyValid : Bool
    , visibility : Bool
    , error : List String
    , isSaving : Bool
    }


initModel : Model
initModel =
    { code = ""
    , isKeyValid = True
    , visibility = True
    , error = []
    , isSaving = False
    }


init : ( Model, List (ReaderCmd Msg) )
init =
    ( initModel
    , [ Strict <| Reader.map (Task.attempt LoadSetting) requestOrganizationSetting ]
    )



-- Update


type Msg
    = LoadSetting (Result GQLClient.Error Setting)
    | ShowCode
    | ChangeToggleVisibility
    | SaveSetting
    | SaveSettingResponse (Result GQLClient.Error Setting)


update : Msg -> Model -> ( Model, List (ReaderCmd Msg) )
update msg model =
    case msg of
        ShowCode ->
            ( model, [] )

        ChangeToggleVisibility ->
            ( { model | visibility = not model.visibility }, [] )

        SaveSetting ->
            save model

        SaveSettingResponse (Ok settingResp) ->
            ( { model
                | visibility = settingResp.visibility
                , isSaving = False
              }
            , []
            )

        SaveSettingResponse (Err error) ->
            ( { model | error = [ "There was an error saving this setting." ], isSaving = False }, [] )

        LoadSetting (Ok setting) ->
            ( { model | visibility = setting.visibility }, [] )

        LoadSetting (Err err) ->
            ( { model | error = [ "There was an error loading setting" ] }, [] )



-- View


settingStatus : Bool -> String
settingStatus visibility =
    case visibility of
        True ->
            "enable"

        False ->
            "disable"


settingInputs : Model -> UpdateSettingInputs
settingInputs { visibility } =
    { visibility = settingStatus visibility
    }


save : Model -> ( Model, List (ReaderCmd Msg) )
save model =
    ( { model | error = [], isSaving = True }
    , [ Strict <|
            Reader.map (Task.attempt SaveSettingResponse)
                (requestUpdateVisibilitySetting (settingInputs model))
      ]
    )


view : NodeEnv -> ApiKey -> AppUrl -> Model -> Html Msg
view nodeEnv organizationKey appUrl model =
    case model.isKeyValid of
        True ->
            widgetSettingsView nodeEnv organizationKey appUrl model

        False ->
            errorAlertView model.error


widgetSettingsView : NodeEnv -> ApiKey -> AppUrl -> Model -> Html Msg
widgetSettingsView nodeEnv organizationKey appUrl model =
    div
        []
        [ errorAlertView model.error
        , div
            [ class "content-header" ]
            [ text "Widget Settings" ]
        , div
            [ class "content-text" ]
            [ text "Insert the following script before the closing body tag of your site or app to display AceHelp's widget on your website." ]
        , div []
            [ textarea
                [ class "js-snippet"
                , disabled True
                ]
                [ text (codeSnippet nodeEnv organizationKey appUrl model)
                ]
            ]
        , hr [] []
        , div [ class "row toggle" ]
            [ div [ class "col-md-4 toggle-label" ] [ text "Enable Widget" ]
            , div [ class "col-md-8" ]
                [ div []
                    [ label [ class "label toggle" ]
                        [ input
                            [ type_ "checkbox"
                            , class "toggle_input"
                            , checked model.visibility
                            , onClick ChangeToggleVisibility
                            ]
                            []
                        , div [ class "toggle-control" ] []
                        ]
                    ]
                , div [ class "hint-text" ]
                    [ text "Note: If you disable the widget, you can still open it via javascript code using the openWidget or openArticle API." ]
                ]
            ]
        , div [ class "row toggle" ]
            [ div [ class "offset-md-10 col-md-2" ]
                [ button
                    [ classList [ ( "btn btn-primary", True ), ( "disabled", model.isSaving ) ]
                    , onClick SaveSetting
                    , disabled model.isSaving
                    ]
                    [ case model.isSaving of
                        True ->
                            text "Saving"

                        False ->
                            text "Save Changes"
                    ]
                ]
            ]
        ]


addBaseUrl nodeEnv appUrl =
    baseUrl nodeEnv appUrl
        |> String.slice 0 -1


codeSnippet : NodeEnv -> ApiKey -> AppUrl -> Model -> String
codeSnippet nodeEnv organizationKey appUrl { visibility } =
    "<script>"
        ++ "var req=new XMLHttpRequest,baseUrl='"
        ++ addBaseUrl nodeEnv appUrl
        ++ "',apiKey='"
        ++ organizationKey
        ++ "',script=document.createElement('script');script.type='text/javascript',script.async=!0,script.onload=function(){var e=window.AceHelp;e&&e._internal.insertWidget({apiKey:apiKey})};var link=document.createElement('link');link.rel='stylesheet',link.type='text/css',link.media='all',req.responseType='json',req.open('GET',baseUrl+'/packs/manifest.json',!0),req.onload=function(){var e=document.getElementsByTagName('script')[0],t=req.response;link.href=baseUrl+t['client.css'],script.src=baseUrl+t['client.js'],e.parentNode.insertBefore(link,e),e.parentNode.insertBefore(script,e)},req.send();"
        ++ "\n</script>"
