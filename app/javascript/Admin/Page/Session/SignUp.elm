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
    , email = Field (validateEmpty "Email") ""
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
    | SignUp
    | SignUpResponse (Result GQLClient.Error User)
    | ForgotPasswordRedirect


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
            in
                if isAllValid fields then
                    signUp model
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
            ( { model | error = Just (toString error) }, [] )


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
    div [ class "pageWrap" ]
        [ div [ class "container" ]
            [ div [ class "pageContent row" ]
                [ div [ class "col-md-12" ]
                    [ h2 [ class "formHeader" ]
                        [ text "Sign-Up to AceHelp" ]
                    ]
                , div [ class "centerForm col-md-12" ]
                    [ Html.form [ onSubmit SignUp ]
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
                        , div [ class "formSection" ]
                            [ button
                                [ type_ "submit"
                                , class "btn btn-primary"
                                ]
                                [ text "Sign Up" ]
                            ]
                        , div [ class "formSection row" ]
                            [ span [ class "btn col-md-6" ]
                                [ Html.a
                                    [ href "/users/sign_in" ]
                                    [ span [] [ text "Sign In" ] ]
                                ]
                            , span [ class "btn" ]
                                [ Html.a
                                    [ href "/users/forgot_password" ]
                                    [ span [] [ text "Forgot password" ] ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]
