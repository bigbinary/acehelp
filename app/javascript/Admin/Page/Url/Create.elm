module Page.Url.Create exposing (Model, Msg(..), init, initModel, save, update, view)

import Admin.Data.ReaderCmd exposing (..)
import Admin.Data.Setting exposing (..)
import Admin.Data.Url exposing (..)
import Admin.Request.Setting exposing (..)
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
import Request.Helpers exposing (ApiKey, NodeEnv)
import Route
import Task exposing (Task)



-- MODEL


type alias Model =
    { errors : List String
    , id : String
    , url : Field String String
    , urlTitle : Field String String
    , baseUrl : Maybe String
    }


initModel : Model
initModel =
    { errors = []
    , id = "0"
    , url = Field validateUrl ""
    , urlTitle = Field (validateEmpty "Title") ""
    , baseUrl = Nothing
    }


init : ( Model, List (ReaderCmd Msg) )
init =
    ( initModel
    , [ Strict <| Reader.map (Task.attempt LoadSetting) requestOrganizationSetting ]
    )



-- UPDATE


type Msg
    = UrlInput String
    | TitleInput String
    | SaveUrl
    | SaveUrlResponse (Result GQLClient.Error UrlResponse)
    | LoadSetting (Result GQLClient.Error Setting)


update : Msg -> Model -> ( Model, List (ReaderCmd Msg) )
update msg model =
    case msg of
        UrlInput url ->
            let
                newUrl =
                    unless
                        (String.startsWith <| Maybe.withDefault "" model.baseUrl)
                        (always <| Maybe.withDefault "" model.baseUrl)
                        url
            in
            ( { model | url = Field.update model.url newUrl }, [] )

        TitleInput title ->
            ( { model | urlTitle = Field.update model.urlTitle title }, [] )

        SaveUrl ->
            let
                fields =
                    [ model.url, model.urlTitle ]

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

        SaveUrlResponse (Ok id) ->
            -- NOTE: Redirection handled in Main
            ( model, [] )

        SaveUrlResponse (Err error) ->
            ( { model | errors = [ "An error occured while saving the Url" ] }, [] )

        LoadSetting (Ok setting) ->
            let
                baseUrl =
                    Maybe.map
                        (unless
                            (String.endsWith "/")
                            (flip String.append "/")
                        )
                        setting.base_url
            in
            ( { model
                | baseUrl = baseUrl
                , url = Field.update model.url (Maybe.withDefault "" baseUrl)
                , errors = []
              }
            , []
            )

        LoadSetting (Err err) ->
            ( { model | errors = [ "Something went wrong while fetching the base Url" ] }, [] )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "url-container row" ]
        [ Html.form [ onSubmit SaveUrl ]
            [ errorView model.errors
            , div []
                [ label [] [ text "URL: " ]
                , input
                    [ type_ "text"
                    , placeholder "Url..."
                    , onInput UrlInput
                    , required True
                    , autofocus True
                    , id "url-input"
                    , Html.Attributes.value <| Field.value model.url
                    ]
                    []
                ]
            , div []
                [ label [] [ text "URL Title: " ]
                , input
                    [ type_ "text"
                    , placeholder "Title..."
                    , onInput TitleInput
                    , required True
                    ]
                    []
                ]
            , button [ type_ "submit", class "btn btn-primary" ] [ text "Save URL" ]
            ]
        ]


save : Model -> ( Model, List (ReaderCmd Msg) )
save model =
    let
        cmd =
            Strict <| Reader.map (Task.attempt SaveUrlResponse) (createUrl { url = Field.value model.url })
    in
    ( model, [ cmd ] )
