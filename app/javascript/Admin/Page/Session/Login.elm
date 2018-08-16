module Page.Session.Login exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Field exposing (..)
import Field.ValidationResult exposing (..)
import GraphQL.Client.Http as GQLClient
import Helpers exposing (..)
import Admin.Request.Session exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)
import Request.Helpers exposing (..)


-- MODEL


type alias Model =
    { error : List String
    , username : Field String String
    , password : Field String String
    }


init : ( Model, Cmd Msg )
init =
    ( { error = []
      , username = Field (validateEmpty "Username") ""
      , password = Field (validateEmpty "Password") ""
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = Login
    | ForgotPassword
    | Signup
    | SetUsername String
    | SetPassword String
    | LoginResponse (Result GQLClient.Error String)


update : Msg -> Model -> NodeEnv -> ( Model, Cmd Msg )
update msg model nodeEnv =
    case msg of
        Login ->
            let
                error =
                    validateAll [ model.username, model.password ]
                        |> filterFailures
                        |> List.map
                            (\result ->
                                case result of
                                    Failed err ->
                                        err

                                    Passed _ ->
                                        "Unknown Error"
                            )

                cmd =
                    case isAllValid [ model.username, model.password ] of
                        True ->
                            Task.attempt LoginResponse
                                (Reader.run
                                    (requestLogin { email = Field.value model.username, password = Field.value model.password })
                                    nodeEnv
                                )

                        False ->
                            Cmd.none
            in
                ( { model | error = error }, cmd )

        LoginResponse (Ok authId) ->
            ( model, Cmd.none )

        LoginResponse (Err err) ->
            ( model, Cmd.none )

        ForgotPassword ->
            ( model, Cmd.none )

        Signup ->
            ( model, Cmd.none )

        SetUsername username ->
            ( { model | username = Field.update model.username username }, Cmd.none )

        SetPassword password ->
            ( { model | password = Field.update model.password password }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container login-container" ]
        [ Html.form []
            [ div [ class "form-group" ]
                [ label [ for "username" ] [ text "Username" ]
                , input [ Html.Attributes.value <| Field.value model.username, type_ "text", class "form-control", id "username", placeholder "Enter email", onInput SetUsername ] []
                ]
            , div [ class "form-group" ]
                [ label [ for "password" ] [ text "Password" ]
                , input [ Html.Attributes.value <| Field.value model.password, type_ "password", class "form-control", id "password", placeholder "Password", onInput SetPassword ] []
                ]
            , button [ type_ "submit", class "btn btn-primary", onClick Login ] [ text "Login" ]
            ]
        ]
