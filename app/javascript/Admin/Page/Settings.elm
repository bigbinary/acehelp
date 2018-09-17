module Page.Settings exposing (Model, Msg(..), codeSnippet, errorView, init, initModel, jsCodeView, update, view)

import Admin.Data.ReaderCmd exposing (..)
import Admin.Request.Helper exposing (ApiKey, AppUrl, NodeEnv, baseUrl)
import Html exposing (..)
import Html.Attributes exposing (..)



-- Model


type alias Model =
    { code : String
    , isKeyValid : Bool
    }


initModel : Model
initModel =
    { code = ""
    , isKeyValid = True
    }


init : ( Model, List (ReaderCmd Msg) )
init =
    ( initModel
    , []
    )



-- Update


type Msg
    = ShowCode


update : Msg -> Model -> ( Model, List (ReaderCmd Msg) )
update msg model =
    ( model, [] )



-- View


view : NodeEnv -> ApiKey -> AppUrl -> Model -> Html Msg
view nodeEnv organizationKey appUrl model =
    case model.isKeyValid of
        True ->
            jsCodeView nodeEnv organizationKey appUrl

        False ->
            errorView


jsCodeView : NodeEnv -> ApiKey -> AppUrl -> Html Msg
jsCodeView nodeEnv organizationKey appUrl =
    div
        []
        [ textarea
            [ class "js-snippet"
            , disabled True
            ]
            [ text (codeSnippet nodeEnv organizationKey appUrl)
            ]
        ]


errorView : Html Msg
errorView =
    div [] [ text "" ]


codeSnippet : NodeEnv -> ApiKey -> AppUrl -> String
codeSnippet nodeEnv organizationKey appUrl =
    "<script>"
        ++ "var req=new XMLHttpRequest,baseUrl='"
        ++ baseUrl nodeEnv appUrl
        ++ "',apiKey='"
        ++ organizationKey
        ++ "',script=document.createElement('script');script.type='text/javascript',script.async=!0,script.onload=function(){var e=window.AceHelp;e&&e._internal.insertWidget({apiKey:apiKey})};var link=document.createElement('link');link.rel='stylesheet',link.type='text/css',link.media='all',req.responseType='json',req.open('GET',baseUrl+'/packs/manifest.json',!0),req.onload=function(){var e=document.getElementsByTagName('script')[0],t=req.response;link.href=baseUrl+t['client.css'],script.src=baseUrl+t['client.js'],e.parentNode.insertBefore(link,e),e.parentNode.insertBefore(script,e)},req.send();"
        ++ "\n</script>"
