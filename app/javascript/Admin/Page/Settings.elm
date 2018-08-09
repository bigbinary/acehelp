module Page.Settings exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Admin.Request.Helper exposing (ApiKey)


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
            [ class "js-snippet"
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
        ++ "var req=new XMLHttpRequest,baseUrl='http://staging.acehelp.com',apiKey='"
        ++ organizationKey
        ++ "',script=document.createElement('script');script.type='text/javascript',script.async=!0,script.onload=function(){var e=window.AceHelp;e&&e._internal.insertWidget({apiKey:apiKey})};var link=document.createElement('link');link.rel='stylesheet',link.type='text/css',link.media='all',req.responseType='json',req.open('GET',baseUrl+'/packs/manifest.json',!0),req.onload=function(){var e=document.getElementsByTagName('script')[0],t=req.response;link.href=baseUrl+t['client.css'],script.src=baseUrl+t['client.js'],e.parentNode.insertBefore(link,e),e.parentNode.insertBefore(script,e)},req.send();"
        ++ "\n</script>"
