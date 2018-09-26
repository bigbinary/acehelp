module Page.Settings.General exposing (Model, Msg(..), init, initModel, save, update, view)

import Admin.Data.Common exposing (..)
import Admin.Data.ReaderCmd exposing (..)
import Admin.Data.Setting exposing (..)
import Admin.Request.Helper exposing (ApiKey, AppUrl, NodeEnv, baseUrl)
import Admin.Request.Setting exposing (..)
import Admin.Views.Common exposing (..)
import Field exposing (..)
import Field.ValidationResult exposing (..)
import GraphQL.Client.Http as GQLClient
import Helpers exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)



-- Model


type alias Model =
    { baseUrl : Field String String
    , currentBaseUrl : String
    , errors : List String
    , isSaving : Bool
    , success : Maybe String
    }


initModel : Model
initModel =
    { baseUrl = Field validateUrl ""
    , currentBaseUrl = ""
    , errors = []
    , isSaving = False
    , success = Nothing
    }


init : ( Model, List (ReaderCmd Msg) )
init =
    ( initModel
    , [ Strict <| Reader.map (Task.attempt LoadSetting) requestOrganizationSetting ]
    )



-- Update


type Msg
    = LoadSetting (Result GQLClient.Error Setting)
    | SaveSetting
    | SaveSettingResponse (Result GQLClient.Error SettingsResponse)
    | InputBaseUrl String


update : Msg -> Model -> ( Model, List (ReaderCmd Msg) )
update msg model =
    case msg of
        SaveSetting ->
            save model

        SaveSettingResponse (Ok newSetting) ->
            case newSetting.setting of
                Just setting ->
                    ( { model
                        | baseUrl = Field.update model.baseUrl <| Maybe.withDefault "" setting.base_url
                        , currentBaseUrl = Maybe.withDefault "" setting.base_url
                        , isSaving = False
                        , errors = []
                        , success = Just "Settings have been updated"
                      }
                    , []
                    )

                Nothing ->
                    ( { model | errors = flattenErrors newSetting.errors, success = Nothing }, [] )

        SaveSettingResponse (Err error) ->
            ( { model
                | errors = [ "There was an error saving the base url" ]
                , isSaving = False
                , success = Nothing
              }
            , []
            )

        LoadSetting (Ok setting) ->
            ( { model
                | baseUrl = Field.update model.baseUrl <| Maybe.withDefault "" setting.base_url
                , currentBaseUrl = Maybe.withDefault "" setting.base_url
                , success = Nothing
                , errors = []
              }
            , []
            )

        LoadSetting (Err err) ->
            ( { model | errors = [ "There was an error loading settings" ], success = Nothing }, [] )

        InputBaseUrl baseUrl ->
            ( { model | baseUrl = Field.update model.baseUrl baseUrl }, [] )



-- View


save : Model -> ( Model, List (ReaderCmd Msg) )
save model =
    case Field.validate model.baseUrl of
        Passed _ ->
            ( { model | errors = [], isSaving = True, success = Nothing }
            , [ Strict <|
                    Reader.map (Task.attempt SaveSettingResponse)
                        (requestUpdateBaseUrlSetting { base_url = Field.value model.baseUrl })
              ]
            )

        Failed err ->
            ( { model | errors = [ err ] }, [] )


view : NodeEnv -> ApiKey -> AppUrl -> Model -> Html Msg
view nodeEnv organizationKey appUrl model =
    div
        []
        [ errorView model.errors
        , successView model.success
        , div
            [ class "content-header" ]
            [ text "General Settings" ]
        , div
            [ class "content-text" ]
            [ text "Set the base Url for your website" ]
        , div [ class "row" ]
            [ div [ class "col-md-4" ]
                [ input
                    [ type_ "text"
                    , Html.Attributes.value <| Field.value model.baseUrl
                    , onInput InputBaseUrl
                    , class "form-control"
                    , placeholder "https://www.example.com"
                    ]
                    []
                ]
            ]
        , div [ class "row" ]
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
