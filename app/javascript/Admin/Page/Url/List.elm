module Page.Url.List exposing (Model, Msg(..), deleteRecord, init, initModel, update, urlRow, view)

import Admin.Data.Common exposing (..)
import Admin.Data.ReaderCmd exposing (..)
import Admin.Data.Url exposing (..)
import Admin.Request.Helper exposing (ApiKey)
import Admin.Request.Url exposing (..)
import Admin.Views.Common exposing (..)
import Dialog
import GraphQL.Client.Http as GQLClient
import Helpers exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Page.Url.Common exposing (..)
import Reader exposing (Reader)
import Route exposing (..)
import Task exposing (Task)



-- MODEL


type alias Model =
    { urls : List UrlPattern
    , urlId : UrlId
    , error : Maybe String
    , showDeleteUrlConfirmation : Acknowledgement UrlId
    }


initModel : Model
initModel =
    { urls = []
    , urlId = ""
    , error = Nothing
    , showDeleteUrlConfirmation = No
    }


init : ( Model, List (ReaderCmd Msg) )
init =
    ( initModel
    , [ Strict <| Reader.map (Task.attempt UrlLoaded) requestUrls ]
    )



-- UPDATE


type Msg
    = LoadUrl UrlId
    | UrlLoaded (Result GQLClient.Error (Maybe (List UrlSummaryData)))
    | DeleteUrl (Acknowledgement UrlId)
    | DeleteUrlResponse (Result GQLClient.Error UrlId)
    | AcknowledgeDelete (Acknowledgement UrlId)


update : Msg -> Model -> ( Model, List (ReaderCmd Msg) )
update msg model =
    case msg of
        LoadUrl urlId ->
            ( { model | urlId = urlId }, [] )

        UrlLoaded (Ok urls) ->
            case urls of
                Just newUrls ->
                    ( { model | urls = List.map dataToPattern newUrls }, [] )

                Nothing ->
                    ( { model | urls = [], error = Just "There was an error while loading the Url Patterns" }, [] )

        UrlLoaded (Err err) ->
            ( { model | error = Just "There was an error while loading the Url Patterns" }, [] )

        AcknowledgeDelete (Yes urlId) ->
            deleteRecord model urlId

        AcknowledgeDelete No ->
            ( { model | showDeleteUrlConfirmation = No }, [] )

        DeleteUrl (Yes urlId) ->
            ( { model | showDeleteUrlConfirmation = Yes urlId }, [] )

        DeleteUrl No ->
            ( { model | showDeleteUrlConfirmation = No }, [] )

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
                        div
                            [ class "alert alert-danger alert-dismissible fade show"
                            , attribute "role" "alert"
                            ]
                            [ text <| "Error: " ++ err
                            ]
                    )
                    model.error
            ]
        , a
            [ href <| routeToString <| UrlCreate orgKey
            , class "btn btn-primary"
            ]
            [ text "+ Url Pattern" ]
        , div
            [ class "listingSection" ]
            (List.map
                (\url ->
                    urlRow orgKey url
                )
                model.urls
            )
        , Dialog.view <|
            case model.showDeleteUrlConfirmation of
                Yes urlId ->
                    Just
                        (dialogConfig
                            { onDecline = AcknowledgeDelete No
                            , title = "Delete Url Pattern"
                            , body = "Are you sure you want to delete this Url Pattern?"
                            , onAccept = AcknowledgeDelete (Yes urlId)
                            }
                        )

                No ->
                    Nothing
        ]


urlRow : ApiKey -> UrlPattern -> Html Msg
urlRow orgKey url =
    let
        ( rule, pattern ) =
            ruleToString url.rule
    in
    div
        [ id url.id
        , class "listingRow"
        ]
        [ a
            [ class "textColumn", href <| routeToString <| CategoriesToUrlMapping orgKey url.id ]
            [ text "URL ", span [ class ("url-rule " ++ ruleToClass url.rule) ] [ text rule ], span [ class "url-pattern" ] [ text pattern ] ]
        , div [ class "actionButtonColumn" ]
            [ a
                [ href <| routeToString <| UrlEdit orgKey url.id
                , class "actionButton btn btn-primary"
                ]
                [ text "Edit Pattern" ]
            ]
        , div [ class "actionButtonColumn" ]
            [ button
                [ onClick (DeleteUrl (Yes url.id))
                , class "actionButton btn btn-primary deleteUrl"
                ]
                [ text "Delete Pattern" ]
            ]
        ]


deleteRecord : Model -> UrlId -> ( Model, List (ReaderCmd Msg) )
deleteRecord model urlId =
    let
        cmd =
            Strict <| Reader.map (Task.attempt DeleteUrlResponse) (deleteUrl urlId)
    in
    ( { model | showDeleteUrlConfirmation = No }, [ cmd ] )
