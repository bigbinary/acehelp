module Page.Url.Create exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Admin.Request.Url exposing (..)
import Request.Helpers exposing (NodeEnv, ApiKey)
import Admin.Data.Url exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)
import GraphQL.Client.Http as GQLClient
import Field exposing (..)
import Field.ValidationResult exposing (..)
import Helpers exposing (..)


-- MODEL


type alias Model =
    { error : Maybe String
    , id : String
    , url : Field String String
    , urlTitle : Field String String
    }


initModel : Model
initModel =
    { error = Nothing
    , id = "0"
    , url = Field (validateEmpty "Url") ""
    , urlTitle = Field (validateEmpty "Title") ""
    }


init : ( Model, Cmd Msg )
init =
    ( initModel
    , Cmd.none
    )



-- UPDATE


type Msg
    = UrlInput String
    | TitleInput String
    | SaveUrl
    | SaveUrlResponse (Result GQLClient.Error UrlData)


update : Msg -> Model -> NodeEnv -> ApiKey -> ( Model, Cmd Msg )
update msg model nodeEnv organizationKey =
    case msg of
        UrlInput url ->
            ( { model | url = Field.update model.url url }, Cmd.none )

        TitleInput title ->
            ( { model | urlTitle = Field.update model.urlTitle title }, Cmd.none )

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
                        |> String.join ", "
            in
                if isAllValid fields then
                    save model nodeEnv
                else
                    ( { model | error = Just errors }, Cmd.none )

        SaveUrlResponse (Ok id) ->
            ( { model
                | url = Field.update model.url ""
                , urlTitle = Field.update model.urlTitle ""
                , error = Nothing
              }
            , Cmd.none
            )

        SaveUrlResponse (Err error) ->
            ( { model | error = Just (toString error) }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ Html.form [ onSubmit SaveUrl ]
            [ div []
                [ Maybe.withDefault (text "") <|
                    Maybe.map
                        (\err ->
                            div [ class "alert alert-danger alert-dismissible fade show", attribute "role" "alert" ]
                                [ text <| "Error: " ++ err
                                ]
                        )
                        model.error
                ]
            , div []
                [ label [] [ text "URL: " ]
                , input
                    [ type_ "text"
                    , placeholder "Url..."
                    , onInput UrlInput
                    ]
                    []
                ]
            , div []
                [ label [] [ text "URL Title: " ]
                , input
                    [ type_ "text"
                    , placeholder "Title..."
                    , onInput TitleInput
                    ]
                    []
                ]
            , button [ type_ "submit", class "button primary" ] [ text "Save URL" ]
            ]
        ]


save : Model -> NodeEnv -> ( Model, Cmd Msg )
save model nodeEnv =
    let
        cmd =
            Task.attempt SaveUrlResponse (Reader.run (createUrl) ( nodeEnv, { url = Field.value model.url } ))
    in
        ( model, cmd )
