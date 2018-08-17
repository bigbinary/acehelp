module Page.Url.List exposing (..)

import Admin.Data.Url exposing (..)
import Admin.Request.Url exposing (..)
import GraphQL.Client.Http as GQLClient
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)
import Admin.Data.ReaderCmd exposing (..)


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
    | UrlLoaded (Result GQLClient.Error (List UrlData))
    | DeleteUrl String
    | DeleteUrlResponse (Result GQLClient.Error UrlId)
    | OnUrlCreateClick
    | OnUrlEditClick UrlId


update : Msg -> Model -> ( Model, List (ReaderCmd Msg) )
update msg model =
    case msg of
        LoadUrl urlId ->
            ( { model | urlId = urlId }, [] )

        UrlLoaded (Ok urls) ->
            ( { model | urls = urls }, [] )

        UrlLoaded (Err err) ->
            ( { model | error = Just (toString err) }, [] )

        DeleteUrl urlId ->
            deleteRecord model urlId

        DeleteUrlResponse (Ok id) ->
            ( { model | urls = List.filter (\m -> m.id /= id) model.urls }, [] )

        DeleteUrlResponse (Err error) ->
            ( { model | error = Just (toString error) }, [] )

        OnUrlCreateClick ->
            -- Note: Handled in Main
            ( model, [] )

        OnUrlEditClick _ ->
            -- Note: Handled in Main
            ( model, [] )



-- VIEW


view : Model -> Html Msg
view model =
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
        , button
            [ onClick OnUrlCreateClick
            , class "btn btn-primary"
            ]
            [ text "New Url" ]
        , div
            [ class "listingSection" ]
            (List.map
                (\url ->
                    urlRow url
                )
                model.urls
            )
        ]


urlRow : UrlData -> Html Msg
urlRow url =
    div
        [ id url.id
        , class "listingRow"
        ]
        [ div
            [ class "textColumn" ]
            [ text url.url ]
        , div [ class "actionButtonColumn" ]
            [ button
                [ onClick (OnUrlEditClick url.id)
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
