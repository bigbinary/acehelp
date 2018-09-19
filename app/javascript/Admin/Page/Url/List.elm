module Page.Url.List exposing (Model, Msg(..), deleteRecord, init, initModel, update, urlRow, view)

import Admin.Data.ReaderCmd exposing (..)
import Admin.Data.Url exposing (..)
import Admin.Request.Helper exposing (ApiKey)
import Admin.Request.Url exposing (..)
import GraphQL.Client.Http as GQLClient
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Reader exposing (Reader)
import Route exposing (..)
import Task exposing (Task)



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


init : ( Model, List (ReaderCmd Msg) )
init =
    ( initModel
    , [ Strict <| Reader.map (Task.attempt UrlLoaded) requestUrls ]
    )



-- UPDATE


type Msg
    = LoadUrl UrlId
    | UrlLoaded (Result GQLClient.Error (Maybe (List UrlData)))
    | DeleteUrl String
    | DeleteUrlResponse (Result GQLClient.Error UrlId)


update : Msg -> Model -> ( Model, List (ReaderCmd Msg) )
update msg model =
    case msg of
        LoadUrl urlId ->
            ( { model | urlId = urlId }, [] )

        UrlLoaded (Ok urls) ->
            case urls of
                Just newUrls ->
                    ( { model | urls = newUrls }, [] )

                Nothing ->
                    ( { model | urls = [], error = Just "There was an error while loading the Urls" }, [] )

        UrlLoaded (Err err) ->
            ( { model | error = Just "There was an error while loading the Urls" }, [] )

        DeleteUrl urlId ->
            deleteRecord model urlId

        DeleteUrlResponse (Ok id) ->
            ( { model | urls = List.filter (\m -> m.id /= id) model.urls }, [] )

        DeleteUrlResponse (Err error) ->
            ( { model | error = Just "An error occured while deleting the Url" }, [] )



-- VIEW


view : ApiKey -> Model -> Html Msg
view orgKey model =
    div
        [ id "url_listing" ]
        [ div
            []
            [ Maybe.withDefault (text "") <|
                Maybe.map
                    (\err ->
                        div [ class "alert alert-danger alert-dismissible fade show", attribute "role" "alert" ]
                            [ text <| "Error: " ++ err
                            ]
                    )
                    model.error
            ]
        , a
            [ href <| routeToString <| UrlCreate orgKey
            , class "btn btn-primary"
            ]
            [ text "+ Url" ]
        , div
            [ class "listingSection" ]
            (List.map
                (\url ->
                    urlRow orgKey url
                )
                model.urls
            )
        ]


urlRow : ApiKey -> UrlData -> Html Msg
urlRow orgKey url =
    div
        [ id url.id
        , class "listingRow"
        ]
        [ div
            [ class "textColumn" ]
            [ text url.url ]
        , div [ class "actionButtonColumn" ]
            [ a
                [ href <| routeToString <| UrlEdit orgKey url.id
                , class "actionButton btn btn-primary"
                ]
                [ text "Edit Url" ]
            ]
        , div [ class "actionButtonColumn" ]
            [ button
                [ onClick (DeleteUrl url.id)
                , class "actionButton btn btn-primary deleteUrl"
                ]
                [ text "Delete Url" ]
            ]
        ]


deleteRecord : Model -> UrlId -> ( Model, List (ReaderCmd Msg) )
deleteRecord model urlId =
    let
        cmd =
            Strict <| Reader.map (Task.attempt DeleteUrlResponse) (deleteUrl urlId)
    in
    ( model, [ cmd ] )
