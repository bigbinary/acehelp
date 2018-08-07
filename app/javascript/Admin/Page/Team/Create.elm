module Page.Team.Create exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Admin.Request.Team exposing (..)
import Admin.Data.Team exposing (..)
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
    , firstName : String
    , lastName : String
    , email : Field String String
    }


initModel : Model
initModel =
    { error = Nothing
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
    = FirstNameInput String
    | LastNameInput String
    | EmailInput String
    | SaveTeam
    | SaveTeamResponse (Result GQLClient.Error Team)


update : Msg -> Model -> NodeEnv -> ApiKey -> ( Model, Cmd Msg )
update msg model nodeEnv organizationKey =
    case msg of
        FirstNameInput firstName ->
            ( { model | firstName = firstName }, Cmd.none )

        LastNameInput lastName ->
            ( { model | lastName = lastName }, Cmd.none )

        EmailInput email ->
            ( { model | email = Field.update model.email email }, Cmd.none )

        SaveTeam ->
            let
                fields =
                    [ model.email ]

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

        SaveTeamResponse (Ok id) ->
            ( model, Route.modifyUrl <| Route.TeamList organizationKey )

        SaveTeamResponse (Err error) ->
            ( { model | error = Just (toString error) }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ Html.form [ onSubmit SaveTeam ]
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
                [ label [] [ text "First Name : " ]
                , input
                    [ type_ "text"
                    , placeholder "First Name"
                    , onInput FirstNameInput
                    ]
                    []
                ]
            , div []
                [ label [] [ text "Last Name: " ]
                , input
                    [ type_ "text"
                    , placeholder "Last Name"
                    , onInput LastNameInput
                    ]
                    []
                ]
            , div []
                [ label [] [ text "Email : " ]
                , input
                    [ type_ "text"
                    , placeholder "Email"
                    , onInput EmailInput
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
            Task.attempt SaveTeamResponse
                (Reader.run (createTeamMember)
                    ( nodeEnv
                    , apiKey
                    , { email = Field.value model.email
                      , firstName = model.firstName
                      , lastName = model.lastName
                      }
                    )
                )
    in
        ( model, cmd )
