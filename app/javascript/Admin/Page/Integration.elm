module Page.Integration exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Request.RequestHelper exposing (ApiKey)


-- Model


type alias Model =
    { code : String
    , organizationKey : ApiKey
    , isKeyValid : Bool
    }


initModel : ApiKey -> Model
initModel organizationKey =
    { code = ""
    , isKeyValid = True
    , organizationKey = organizationKey
    }


init : ApiKey -> ( Model, Cmd Msg )
init organizationKey =
    ( initModel organizationKey
    , Cmd.none
    )



-- Update


type Msg
    = ShowCode


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



-- View


view : Model -> Html Msg
view model =
    case model.isKeyValid of
        True ->
            jsCodeView model.organizationKey

        False ->
            errorView


jsCodeView : ApiKey -> Html Msg
jsCodeView organizationKey =
    div
        []
        [ textarea
            [ class "code disabled"
            , disabled True
            ]
            [ text (codeSnippet organizationKey)
            ]
        ]


errorView : Html Msg
errorView =
    div [] [ text "" ]


codeSnippet : ApiKey -> String
codeSnippet organizationKey =
    "<script>"
        ++ "\nvar req=new XMLHttpRequest,script=document.createElement('script')"
        ++ ",link=document.createElement('link'),baseUrl='',apiKey='"
        ++ organizationKey
        ++ "'"
        ++ "cript.type='text/javascript',script.async=!0,"
        ++ "script.onload=function(){var e=window._ace;e&&e.insertWidget({apiKey:apiKey})},"
        ++ "link.rel='stylesheet',link.type='text/css',link.media='all',"
        ++ "req.responseType='json',"
        ++ "req.open('GET',baseUrl+'/packs/manifest.json',!0),"
        ++ "req.onload=function(){"
        ++ "var e=document.getElementsByTagName('script')[0],t=req.response;"
        ++ "link.href=baseUrl+t['client.css'],script.src=baseUrl+t['client.js'],e.parentNode.insertBefore(link,e),e.parentNode.insertBefore(script,e)"
        ++ "},"
        ++ "req.send();"
        ++ "\n</script>"
