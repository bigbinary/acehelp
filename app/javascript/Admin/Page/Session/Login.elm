module Page.Session.Login exposing (Model, Msg(..), init, initModel, update, view)

import Admin.Data.ReaderCmd exposing (..)
import Admin.Data.Session exposing (..)
import Admin.Data.User exposing (..)
import Admin.Request.Session exposing (..)
import Field exposing (..)
import Field.ValidationResult exposing (..)
import GraphQL.Client.Http as GQLClient
import Helpers exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Reader exposing (Reader)
import Route exposing (..)
import Task exposing (Task)



-- MODEL


type alias Model =
    { error : List String
    , username : Field String String
    , password : Field String String
    }


initModel : Model
initModel =
    { username = Field (validateEmpty "Username") ""
    , password = Field (validateEmpty "Password") ""
    , error = []
    }


init : ( Model, List (ReaderCmd Msg) )
init =
    ( initModel
    , []
    )



-- UPDATE


type Msg
    = Login
    | SetUsername String
    | SetPassword String
    | LoginResponse (Result GQLClient.Error UserWithOrganization)


update : Msg -> Model -> ( Model, List (ReaderCmd Msg) )
update msg model =
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
                            [ Open <|
                                Reader.map
                                    (Task.attempt LoginResponse)
                                    (requestLogin { email = Field.value model.username, password = Field.value model.password })
                            ]

                        False ->
                            []
            in
            ( { model | error = error }, cmd )

        LoginResponse (Ok authId) ->
            ( model, [] )

        LoginResponse (Err err) ->
            ( { model | error = [ "Username or Password is incorrect. Please try again" ] }, [] )

        SetUsername username ->
            ( { model | username = Field.update model.username username }, [] )

        SetPassword password ->
            ( { model | password = Field.update model.password password }, [] )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "page-wrap" ]
        [ div [ class "container login-container" ]
            [ div [ class "page-content row" ]
                [ div [ class "col-md-12" ]
                    [ h2 [ class "form-header" ] [ text "Sign-In to AceHelp" ]
                    ]
                , div [ class "center-form col-md-12" ]
                    [ case model.error of
                        [] ->
                            text ""

                        _ ->
                            div []
                                [ div
                                    [ class "alert alert-danger"
                                    ]
                                    (List.map
                                        (\er -> div [] [ text er ])
                                        model.error
                                    )
                                ]
                    , div []
                        [ div [ class "form-group" ]
                            [ input
                                [ Html.Attributes.value <|
                                    Field.value model.username
                                , type_ "text"
                                , class "form-control"
                                , id "username"
                                , placeholder "Email address"
                                , onInput SetUsername
                                ]
                                []
                            ]
                        , div [ class "form-group" ]
                            [ input
                                [ Html.Attributes.value <|
                                    Field.value model.password
                                , type_ "password"
                                , class "form-control"
                                , id "password"
                                , placeholder "Password"
                                , onInput SetPassword
                                ]
                                []
                            ]
                        ]
                    , div [ class "form-section" ]
                        [ button
                            [ type_ "button"
                            , class "btn-login btn btn-primary"
                            , onClick Login
                            ]
                            [ text "Login" ]
                        ]
                    ]
                , div [ class "links-section col-md-12" ]
                    [ span [ class "btn" ]
                        [ Html.a
                            [ href <| routeToString <| SignUp ]
                            [ span [] [ text "Sign Up" ] ]
                        ]
                    , span [ class "btn" ]
                        [ Html.a
                            [ href <| routeToString <| ForgotPassword ]
                            [ span [] [ text "Forgot password" ] ]
                        ]
                    ]
                ]
            ]
        ]
