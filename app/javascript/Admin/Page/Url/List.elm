module Page.Url.List exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Navigation exposing (..)
import Route
import Request.UrlRequest exposing (..)
import Request.RequestHelper exposing (..)
import Data.UrlData exposing (..)
import Data.CommonData exposing (Error)
import Page.Common.View exposing (renderError)
import Reader exposing (Reader)
import Task exposing (Task)
import GraphQL.Client.Http as GQLClient


-- MODEL


type alias Model =
    { listOfUrls : List UrlData
    , urlId : UrlId
    , error : Error
    }


initModel : Model
initModel =
    { listOfUrls = []
    , urlId = ""
    , error = Nothing
    }


init : NodeEnv -> ApiKey -> ( Model, Cmd Msg )
init env key =
    ( initModel
    , (fetchUrlList env)
    )



-- UPDATE


type Msg
    = LoadUrl UrlId
    | UrlLoaded (Result GQLClient.Error (List UrlData))
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
                model.listOfUrls
            )
        ]


urlRow : UrlData -> Html Msg
urlRow url =
    div []
        [ text url.url ]


fetchUrlList : NodeEnv -> Cmd Msg
fetchUrlList env =
    Task.attempt UrlLoaded (Reader.run (requestUrls) (env))
