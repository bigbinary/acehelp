module Page.Session.SignUp exposing (..)

import Admin.Data.ReaderCmd exposing (..)
import Admin.Data.User exposing (..)
import Admin.Request.Session exposing (signupRequest)
import Field exposing (..)
import Field.ValidationResult exposing (..)
import GraphQL.Client.Http as GQLClient
import Helpers exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Reader exposing (Reader)
import Regex exposing (Regex)
import Task exposing (Task)


-- MODEL


type alias Model =
    { firstName : Field String String
    , email : Field String String
    , password : Field String String
    , confirmPassword : Field String String
    , error : Maybe String
    }


initModel : Model
initModel =
    { firstName = Field (validateEmpty "First Name") ""
    , email = Field (validateEmpty "Email" >> andThen validateEmail) ""
    , password = Field (validateEmpty "Password") ""
    , confirmPassword = Field (validateEmpty "Confirm Password") ""
    , error = Nothing
    }


init : ( Model, List (ReaderCmd Msg) )
init =
    ( initModel, [] )



-- UPDATE


type Msg
    = FirstNameInput String
    | EmailInput String
    | PasswordInput String
    | ConfirmPasswordInput String
    | ForgotPasswordRedirect
    | LoginRedirect
    | SignUp
    | SignUpResponse (Result GQLClient.Error User)
    | HideError


update : Msg -> Model -> ( Model, List (ReaderCmd Msg) )
update msg model =
    case msg of
        FirstNameInput firstName ->
            ( { model | firstName = Field.update model.firstName firstName }, [] )

        EmailInput email ->
            ( { model | email = Field.update model.email email }, [] )

        PasswordInput password ->
            ( { model | password = Field.update model.password password }, [] )

        ConfirmPasswordInput password ->
            ( { model | confirmPassword = Field.update model.confirmPassword password }, [] )

        ForgotPasswordRedirect ->
            ( model, [] )

        LoginRedirect ->
            ( model, [] )

        SignUp ->
            let
                fields =
                    [ model.firstName, model.email, model.password, model.confirmPassword ]

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

                formValidation =
                    isAllValid fields

                passwordValidation =
                    (Field.value model.password) == (Field.value model.confirmPassword)
            in
                if formValidation && passwordValidation then
                    signUp model
                else if not passwordValidation then
                    ( { model | error = Just "Please enter valid passwords" }, [] )
                else
                    ( { model | error = Just errors }, [] )

        SignUpResponse (Ok user) ->
            ( { model
                | firstName = Field.update model.firstName ""
                , email = Field.update model.email ""
                , password = Field.update model.password ""
                , confirmPassword = Field.update model.confirmPassword ""
              }
            , []
            )

        SignUpResponse (Err error) ->
            case error of
                GQLClient.HttpError err ->
                    ( { model | error = Just "Something went wrong. Please try again" }, [] )

                GQLClient.GraphQLError err ->
                    ( { model | error = Just <| String.join ". " <| List.map .message err }, [] )

        HideError ->
            ( { model | error = Nothing }, [] )


signUp : Model -> ( Model, List (ReaderCmd Msg) )
signUp model =
    let
        cmd =
            Open <|
                Reader.map (Task.attempt SignUpResponse)
                    (signupRequest
                        { firstName = Field.value model.firstName
                        , email = Field.value model.email
                        , password = Field.value model.password
                        , confirmPassword = Field.value model.confirmPassword
                        }
                    )
    in
        ( model, [ cmd ] )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "page-wrap" ]
        [ div [ class "container" ]
            [ div [ class "page-content row" ]
                [ div [ class "col-md-12" ]
                    [ h2 [ class "form-header" ]
                        [ text "Sign-Up to AceHelp" ]
                    ]
                , div [ class "center-form col-md-12" ]
                    [ div []
                        [ Maybe.withDefault (text "") <|
                            Maybe.map
                                (\err ->
                                    div
                                        [ class "alert alert-danger"
                                        ]
                                        [ span
                                            [ class "close-error-icon"
                                            , onClick HideError
                                            ]
                                            []
                                        , text <| "Error: " ++ err
                                        ]
                                )
                                model.error
                        ]
                    , div []
                        [ div [ class "form-group" ]
                            [ input
                                [ Html.Attributes.value <|
                                    Field.value model.firstName
                                , type_ "text"
                                , placeholder "First Name"
                                , onInput FirstNameInput
                                , class "form-control"
                                ]
                                []
                            ]
                        , div [ class "form-group" ]
                            [ input
                                [ Html.Attributes.value <|
                                    Field.value model.email
                                , type_ "text"
                                , placeholder "Email"
                                , onInput EmailInput
                                , class "form-control"
                                ]
                                []
                            ]
                        , div [ class "form-group" ]
                            [ input
                                [ Html.Attributes.value <|
                                    Field.value model.password
                                , type_ "password"
                                , placeholder "Password"
                                , onInput PasswordInput
                                , class "form-control"
                                ]
                                []
                            ]
                        , div [ class "form-group" ]
                            [ input
                                [ Html.Attributes.value <|
                                    Field.value model.confirmPassword
                                , type_ "password"
                                , placeholder "Confirm Password"
                                , onInput ConfirmPasswordInput
                                , class "form-control"
                                ]
                                []
                            ]
                        , div [ class "form-section" ]
                            [ button
                                [ type_ "submit"
                                , class "btn btn-primary"
                                , onClick SignUp
                                ]
                                [ text "Sign Up" ]
                            ]
                        , div [ class "form-section row" ]
                            [ span
                                [ class "col-md-6 btn btn-link"
                                , onClick LoginRedirect
                                ]
                                [ text "Sign In" ]
                            , span
                                [ class "btn btn-link"
                                , onClick ForgotPasswordRedirect
                                ]
                                [ text "Forgot password" ]
                            ]
                        ]
                    ]
                ]
            ]
        ]
