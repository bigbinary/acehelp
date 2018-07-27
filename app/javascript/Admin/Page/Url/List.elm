module Page.Url.List exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Navigation exposing (..)
import Route
import Admin.Request.Url exposing (..)
import Admin.Request.Helper exposing (..)
import Admin.Data.Url exposing (..)
import Page.Common.View exposing (renderError)
import Reader exposing (Reader)
import Task exposing (Task)
import GraphQL.Client.Http as GQLClient


-- MODEL


type alias Model =
    { urls : List UrlData
    , urlId : UrlId
    , error : Maybe String
    }


initModel : Model
initModel =
    { urls = []
    , urlId = ""
    , error = Nothing
    }


init : ( Model, Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error (List UrlData)) )
init =
    ( initModel
    , requestUrls
    )



-- UPDATE


type Msg
    = LoadUrl UrlId
    | UrlLoaded (Result GQLClient.Error (List UrlData))
    | Navigate Route.Route
    | DeleteUrl String



--| DeleteUrlResponse (Result GQLClient.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadUrl urlId ->
            ( { model | urlId = urlId }, Cmd.none )

        UrlLoaded (Ok urls) ->
            ( { model | urls = urls }, Cmd.none )

        UrlLoaded (Err err) ->
            ( { model | error = Just (toString err) }, Cmd.none )

        Navigate page ->
            model ! [ Navigation.newUrl (Route.routeToString page) ]

        DeleteUrl urlId ->
            delete model



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
                model.urls
            )
        ]


urlRow : UrlData -> Html Msg
urlRow url =
    div []
        [ div
            []
            [ text url.url ]
        , div
            []
            [ Html.a
                [ onClick (DeleteUrl url.id)
                , class "button primary deleteUrl"
                ]
                [ text "Delete Url" ]
            ]
        ]


delete : Model -> ( Model, Cmd Msg )
delete model =
    ( model, Cmd.none )
