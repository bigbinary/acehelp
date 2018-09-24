module Page.Url.Edit exposing (Model, Msg(..), init, initModel, save, update, urlInputs, view)

import Admin.Data.ReaderCmd exposing (..)
import Admin.Data.Url exposing (..)
import Admin.Request.Url exposing (..)
import Admin.Views.Common exposing (errorView)
import Field exposing (..)
import Field.ValidationResult exposing (..)
import GraphQL.Client.Http as GQLClient
import Helpers exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)



-- MODEL


type alias Model =
    { errors : List String
    , success : Maybe String
    , url : Field String String
    , urlId : UrlId
    }


initModel : UrlId -> Model
initModel urlId =
    { errors = []
    , success = Nothing
    , url = Field (validateEmpty "Url") ""
    , urlId = urlId
    }


init : UrlId -> ( Model, List (ReaderCmd Msg) )
init urlId =
    ( initModel urlId
    , [ Strict <| Reader.map (Task.attempt UrlLoaded) (requestUrlById urlId) ]
    )



-- UPDATE


type Msg
    = UrlInput String
    | UpdateUrl
    | UpdateUrlResponse (Result GQLClient.Error UrlResponse)
    | UrlLoaded (Result GQLClient.Error (Maybe UrlData))


update : Msg -> Model -> ( Model, List (ReaderCmd Msg) )
update msg model =
    case msg of
        UrlInput url ->
            ( { model | url = Field.update model.url url }, [] )

        UpdateUrl ->
            let
                fields =
                    [ model.url ]

                errors =
                    validateAll fields
                        |> filterFailures
                        |> List.map
                            (\result ->
                                case result of
                                    Failed err ->
                                        err

                                    Passed _ ->
                                        "Unknown Error"
                            )
            in
            if isAllValid fields then
                save model

            else
                ( { model | errors = errors }, [] )

        UpdateUrlResponse (Ok id) ->
            ( model, [] )

        UpdateUrlResponse (Err error) ->
            ( { model | errors = [ "An error occured while updating the Url information" ] }, [] )

        UrlLoaded (Ok url) ->
            case url of
                Just newUrl ->
                    ( { model
                        | url = Field.update model.url newUrl.url
                        , urlId = newUrl.id
                      }
                    , []
                    )

                Nothing ->
                    ( { model | errors = [ "There was an error while loading the url" ] }, [] )

        UrlLoaded (Err err) ->
            ( { model | errors = [ "There was an error while loading the url" ] }, [] )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ Html.form [ onSubmit UpdateUrl ]
            [ errorView model.errors
            , div []
                [ Maybe.withDefault (text "") <|
                    Maybe.map
                        (\message ->
                            div
                                [ class "alert alert-success alert-dismissible fade show"
                                , attribute "role" "alert"
                                ]
                                [ text <| message
                                ]
                        )
                        model.success
                ]
            , div []
                [ label [] [ text "URL: " ]
                , input
                    [ Html.Attributes.value <| Field.value model.url
                    , type_ "text"
                    , placeholder "Url..."
                    , onInput UrlInput
                    ]
                    []
                ]
            , button [ type_ "submit", class "btn btn-primary" ] [ text "Update URL" ]
            ]
        ]


urlInputs : Model -> UrlData
urlInputs { url, urlId } =
    { url = Field.value url
    , id = urlId
    }


save : Model -> ( Model, List (ReaderCmd Msg) )
save model =
    let
        cmd =
            Strict <| Reader.map (Task.attempt UpdateUrlResponse) (updateUrl <| urlInputs model)
    in
    ( model, [ cmd ] )
