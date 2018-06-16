module Page.Url.List exposing (..)

import Http
import Html exposing (..)
import Html.Attributes exposing (..)
import Request.UrlRequest exposing (..)
import Data.UrlData exposing (..)


-- MODEL


type alias Model =
    { listOfUrls : UrlsListResponse
    , urlId : UrlId
    , error : Maybe String
    }


type alias UrlId =
    Int


init : ( Model, Cmd Msg )
init =
    ( { listOfUrls = { urls = [] }
      , urlId = 0
      , error = Nothing
      }
    , (fetchUrlList)
    )



-- UPDATE


type Msg
    = LoadUrl UrlId
    | UrlLoaded (Result Http.Error UrlsListResponse)


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
            [ class "buttonDiv" ]
            [ a
                [ href "/admin/urls/new"
                , class "button primary"
                ]
                [ text "New Url"
                ]
            ]
        , div []
            (List.map
                (\url ->
                    urlRow url
                )
                model.listOfUrls.urls
            )
        ]


urlRow : UrlData -> Html Msg
urlRow url =
    div []
        [ text url.url ]


fetchUrlList : Cmd Msg
fetchUrlList =
    let
        request =
            requestUrls "dev" "3c60b69a34f8cdfc76a0"

        cmd =
            Http.send UrlLoaded request
    in
        cmd
