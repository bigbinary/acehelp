module Page.Url.List exposing (..)

import Admin.Data.Url exposing (..)
import Admin.Request.Helper exposing (..)
import Admin.Request.Url exposing (..)
import GraphQL.Client.Http as GQLClient
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Navigation exposing (..)
import Reader exposing (Reader)
import Route
import Task exposing (Task)


-- MODEL


type alias Model =
    { urls : List UrlData
    , urlId : UrlId
    , organizationKey : String
    , error : Maybe String
    }


initModel : ApiKey -> Model
initModel organizationKey =
    { urls = []
    , urlId = ""
    , organizationKey = organizationKey
    , error = Nothing
    }


init : ApiKey -> ( Model, Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error (List UrlData)) )
init organizationKey =
    ( initModel organizationKey
    , requestUrls
    )



-- UPDATE


type Msg
    = LoadUrl UrlId
    | UrlLoaded (Result GQLClient.Error (List UrlData))
    | Navigate Route.Route
    | DeleteUrl String
    | DeleteUrlResponse (Result GQLClient.Error UrlId)


update : Msg -> Model -> NodeEnv -> ApiKey -> ( Model, Cmd Msg )
update msg model nodeEnv organizationKey =
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
            deleteRecord model nodeEnv organizationKey { id = urlId }

        DeleteUrlResponse (Ok id) ->
            let
                urls =
                    List.filter (\m -> m.id /= id) model.urls
            in
                ( { model | urls = urls }, Cmd.none )

        DeleteUrlResponse (Err error) ->
            ( { model | error = Just (toString error) }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



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
            [ onClick (Navigate <| Route.UrlCreate model.organizationKey)
            , class "btn btn-primary"
            ]
            [ text "New Url" ]
        , div
            [ class "listingSection" ]
            (List.map
                (\url ->
                    urlRow model url
                )
                model.urls
            )
        ]


urlRow : Model -> UrlData -> Html Msg
urlRow model url =
    div
        [ id url.id
        , class "listingRow"
        ]
        [ div
            [ class "textColumn" ]
            [ text url.url ]
        , div [ class "actionButtonColumn" ]
            [ button
                [ onClick (Navigate <| Route.UrlEdit model.organizationKey url.id)
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


deleteRecord : Model -> NodeEnv -> ApiKey -> UrlIdInput -> ( Model, Cmd Msg )
deleteRecord model nodeEnv apiKey urlId =
    let
        cmd =
            Task.attempt DeleteUrlResponse (Reader.run (deleteUrl) ( nodeEnv, apiKey, urlId ))
    in
        ( model, cmd )
