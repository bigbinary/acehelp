module Page.Team.Create exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Admin.Request.Url exposing (..)
import Request.Helpers exposing (NodeEnv, ApiKey)
import Reader exposing (Reader)
import Task exposing (Task)
import GraphQL.Client.Http as GQLClient
import Field exposing (..)
import Field.ValidationResult exposing (..)
import Helpers exposing (..)
import Route


-- MODEL


type alias Model =
    { error : Maybe String
    , id : String
    , firstName : String
    , lastName : String
    , email : Field String String
    }


initModel : Model
initModel =
    { error = Nothing
    , id = "0"
    , firstName = ""
    , lastName = ""
    , email = Field (validateEmpty "Email") ""
    }


init : ( Model, Cmd Msg )
init =
    ( initModel
    , Cmd.none
    )



-- UPDATE


type Msg
    = FirstName String
    | LastName String
    | Email String
    | SaveTeam
    | SaveTeamResponse (Result GQLClient.Error TeamMemberData)


update : Msg -> Model -> NodeEnv -> ApiKey -> ( Model, Cmd Msg )
update msg model nodeEnv organizationKey =
    case msg of
        FirstName firstName ->
            ( { model | firstName = firstName }, Cmd.none )

        LastName lastName ->
            ( { model | lastName = lastName }, Cmd.none )

        Email email ->
            ( { model | email = email }, Cmd.none )

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
                    save model nodeEnv organizationKey
                else
                    ( { model | error = Just errors }, Cmd.none )

        SaveUrlResponse (Ok id) ->
            ( model, Route.modifyUrl <| Route.UrlList organizationKey )

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
                            div
                                [ class "alert alert-danger alert-dismissible fade show"
                                , attribute "role" "alert"
                                ]
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


save : Model -> NodeEnv -> ApiKey -> ( Model, Cmd Msg )
save model nodeEnv apiKey =
    let
        cmd =
            Task.attempt SaveUrlResponse
                (Reader.run (createUrl)
                    ( nodeEnv
                    , apiKey
                    , { url = Field.value model.url }
                    )
                )
    in
        ( model, cmd )
