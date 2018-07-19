module Page.Url.List exposing (..)

import Http
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Navigation exposing (..)
import Route
import Page.Url.Create as UrlCreate
import Request.UrlRequest exposing (..)
import Data.UrlData exposing (..)
import Data.CommonData exposing (Error)
import Page.Common.View exposing (renderError)


-- MODEL


type alias Model =
    { listOfUrls : UrlsListResponse
    , urlId : UrlId
    , error : Error
    }


initModel : Model
initModel =
    { listOfUrls = { urls = [] }
    , urlId = ""
    , error = Nothing
    }


init : String -> String -> ( Model, Cmd Msg )
init env organizationKey =
    ( initModel
    , (fetchUrlList env organizationKey)
    )



-- UPDATE


type Msg
    = LoadUrl UrlId
    | UrlLoaded (Result Http.Error UrlsListResponse)
    | Navigate Route.Route


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadUrl urlId ->
            ( { model | urlId = urlId }, Cmd.none )

        UrlLoaded (Ok urls) ->
            ( { model | listOfUrls = urls }, Cmd.none )

        UrlLoaded (Err err) ->
            ( { model | error = Just (toString err) }, Cmd.none )

        Navigate page ->
            model ! [ Navigation.newUrl (Route.routeToString page) ]



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
            []
            [ text (renderError model.error)
            ]
        , div
            [ class "buttonDiv" ]
            [ Html.a
                [ onClick (Navigate <| Route.UrlCreate)
                , class "button primary"
                ]
                [ text "New Url" ]
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


fetchUrlList : String -> String -> Cmd Msg
fetchUrlList env key =
    Http.send UrlLoaded (requestUrls env key)
