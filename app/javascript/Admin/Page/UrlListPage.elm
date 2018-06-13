module Page.UrlListPage exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Http


-- MODEL


type alias Model =
    { listOfUrls : String --List Url
    , urlId : UrlId
    , error : Maybe String
    }


type alias Url =
    { url : String
    , urlTitle : String
    }


type alias UrlId =
    Int


init : ( Model, Cmd Msg )
init =
    ( { listOfUrls = "", urlId = 0, error = Nothing }
    , (fetchUrlList "3c60b69a34f8cdfc76a0")
    )



-- UPDATE


type Msg
    = LoadUrl UrlId
    | UrlLoaded (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadUrl urlId ->
            ( { model | urlId = urlId }, Cmd.none )

        UrlLoaded (Ok urls) ->
            ( { model | listOfUrls = urls }, Cmd.none )

        UrlLoaded (Err err) ->
            ( { model | error = Just (toString err) }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div
        []
        [ div
            [ style [ ( "float", "right" ) ] ]
            [ a
                [ href "/admin/urls/new"
                , class "button primary"
                ]
                [ text "New Url"
                ]
            ]
        , text "Url List Page"
        ]


fetchUrlList : String -> Cmd Msg
fetchUrlList orgApiKey =
    let
        url =
            "http://localhost:3000/url"

        request =
            Http.request
                { method = "GET"
                , headers = [ (Http.header "api-key" orgApiKey) ]
                , url = url
                , body = Http.emptyBody
                , expect = Http.expectString
                , timeout = Nothing
                , withCredentials = False
                }

        cmd =
            Http.send UrlLoaded request
    in
        cmd
