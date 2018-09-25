module Page.Settings.General exposing (Model, Msg(..), init, initModel, save, update, view)

import Admin.Data.ReaderCmd exposing (..)
import Admin.Data.Setting exposing (..)
import Admin.Request.Helper exposing (ApiKey, AppUrl, NodeEnv, baseUrl)
import Admin.Request.Setting exposing (..)
import Field exposing (..)
import Field.ValidationResult exposing (..)
import GraphQL.Client.Http as GQLClient
import Helpers exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Page.Errors exposing (errorAlertView)
import Reader exposing (Reader)
import Task exposing (Task)



-- Model


type alias Model =
    { baseUrl : Field validateUrl String
    , currentBaseUrl : String
    , errors : List String
    , isSaving : Bool
    }


initModel : Model
initModel =
    { baseUrl = ""
    , currentBaseUrl = ""
    , errors = []
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
    | SaveSetting
    | SaveSettingResponse (Result GQLClient.Error Setting)
    | InputBaseUrl String


update : Msg -> Model -> ( Model, List (ReaderCmd Msg) )
update msg model =
    case msg of
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
            ( { model | errors = [ "There was an error saving the base url" ], isSaving = False }, [] )

        LoadSetting (Ok setting) ->
            ( { model | baseUrl = setting.base_url, currentBaseUrl = setting.base_url }, [] )

        LoadSetting (Err err) ->
            ( { model | errors = [ "There was an error loading settings" ] }, [] )

        InputBaseUrl baseUrl ->
            {}



-- View


save : Model -> ( Model, List (ReaderCmd Msg) )
save model =
    ( { model | error = [], isSaving = True }
    , [ Strict <|
            Reader.map (Task.attempt SaveSettingResponse)
                (requestUpdateSetting (settingInputs model))
      ]
    )


view : NodeEnv -> ApiKey -> AppUrl -> Model -> Html Msg
view nodeEnv organizationKey appUrl model =
    div
        []
        [ errorAlertView model.error
        , div
            [ class "content-header" ]
            [ text "General Settings" ]
        , div
            [ class "content-text" ]
            [ text "Set the base Url for your website" ]
        , div [ class "row toggle" ]
            [ div [ class "col-md-4 toggle-label" ] [ text "Enable Widget" ]
            , div [ class "col-md-8" ]
                [ div []
                    [ input
                        [ type_ "text"
                        , value model.baseUrl
                        , onInput InputBaseUrl
                        ]
                        []
                    ]
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
