module Page.Settings exposing (Model, Msg(..), codeSnippet, errorView, init, initModel, jsCodeView, update, view)

import Admin.Data.ReaderCmd exposing (..)
import Admin.Request.Helper exposing (ApiKey, AppUrl, NodeEnv, baseUrl)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

-- Model


type alias Model =
    { code : String
    , isKeyValid : Bool
    , makeToggleInvisible : Bool
    }


initModel : Model
initModel =
    { code = ""
    , isKeyValid = True
    , makeToggleInvisible = True
    }


init : ( Model, List (ReaderCmd Msg) )
init =
    ( initModel
    , []
    )



-- Update


type Msg
    = ShowCode
    | ChangeToggleVisibility


update : Msg -> Model -> ( Model, List (ReaderCmd Msg) )
update msg model =
    case msg of
        ShowCode ->
            ( model, [] )

        ChangeToggleVisibility ->
            let
                toggleVisibility =
                    not model.makeToggleInvisible
            in
                ( { model | makeToggleInvisible = toggleVisibility }, [] )



-- View


view : NodeEnv -> ApiKey -> AppUrl -> Model -> Html Msg
view nodeEnv organizationKey appUrl model =
    case model.isKeyValid of
        True ->
            jsCodeView nodeEnv organizationKey appUrl model

        False ->
            errorView


jsCodeView : NodeEnv -> ApiKey -> AppUrl -> Model -> Html Msg
jsCodeView nodeEnv organizationKey appUrl model =
    div
        []
        [ div
            [ class "content-section" ]
            [ textarea
                [ class "js-snippet"
                , disabled True
                ]
                [ text (codeSnippet nodeEnv organizationKey appUrl model)
                ]
            ]
        , div [ class "row toggle" ]
            [ div [ class "col-md-6 toggle-label" ] [ text "Enable Widget" ]
            , div [ class "col-md-6" ]
                [ div []
                    [ label [ class "label toggle" ]
                        [ input
                            [ type_ "checkbox"
                            , class "toggle_input"
                            , checked model.makeToggleInvisible
                            , onClick ChangeToggleVisibility
                            ]
                            []
                        , div [ class "toggle-control" ] []
                        ]
                    ]
                ]
            ]
        ]


errorView : Html Msg
errorView =
    div [] [ text "" ]


codeSnippet : NodeEnv -> ApiKey -> AppUrl -> Model -> String
codeSnippet nodeEnv organizationKey appUrl { makeToggleInvisible } =
    let
        widgetToggleVisibility =
            case makeToggleInvisible of
                True ->
                    "true"

                False ->
                    "false"
    in
        "<script>"
            ++ "var req=new XMLHttpRequest,baseUrl='"
            ++ baseUrl nodeEnv appUrl
            ++ "',apiKey='"
            ++ organizationKey
            ++ "',script=document.createElement('script');script.type='text/javascript',script.async=!0,script.onload=function(){var e=window.AceHelp;e&&e._internal.insertWidget({apiKey:apiKey},"
            ++ widgetToggleVisibility
            ++ ")};var link=document.createElement('link');link.rel='stylesheet',link.type='text/css',link.media='all',req.responseType='json',req.open('GET',baseUrl+'/packs/manifest.json',!0),req.onload=function(){var e=document.getElementsByTagName('script')[0],t=req.response;link.href=baseUrl+t['client.css'],script.src=baseUrl+t['client.js'],e.parentNode.insertBefore(link,e),e.parentNode.insertBefore(script,e)},req.send();'"
            ++ "\n</script>"
