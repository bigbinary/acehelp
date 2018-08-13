module Page.Session.SignUp exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Task exposing (Task)
import Reader exposing (Reader)
import Field exposing (..)
import Field.ValidationResult exposing (..)
import Helpers exposing (..)
import Admin.Data.User exposing (..)
import Admin.Data.Session exposing (..)
import Request.Helpers exposing (NodeEnv, ApiKey)
import Admin.Request.Session exposing (signupRequest)
import GraphQL.Client.Http as GQLClient


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


init : ( Model, Cmd Msg )
init =
    ( initModel, Cmd.none )



-- UPDATE


type Msg
    = FirstNameInput String
    | EmailInput String
    | PasswordInput String
    | ConfirmPasswordInput String
    | SignUp
    | SignUpResponse (Result GQLClient.Error User)


update : Msg -> Model -> NodeEnv -> ApiKey -> ( Model, Cmd Msg )
update msg model nodeEnv apiKey =
    case msg of
        FirstNameInput firstName ->
            ( { model | firstName = Field.update model.firstName firstName }, Cmd.none )

        EmailInput email ->
            ( { model | email = Field.update model.email email }, Cmd.none )

        PasswordInput password ->
            ( { model | password = Field.update model.password password }, Cmd.none )

        ConfirmPasswordInput password ->
            ( { model | confirmPassword = Field.update model.confirmPassword password }, Cmd.none )

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
                    signUp model nodeEnv apiKey
                else
                    ( { model | error = Just errors }, Cmd.none )

        _ ->
            ( model, Cmd.none )


signUp : Model -> NodeEnv -> ApiKey -> ( Model, Cmd Msg )
signUp model nodeEnv apiKey =
    let
        cmd =
            Task.attempt SignUpResponse
                (Reader.run
                    (signupRequest
                        ({ firstName = Field.value model.firstName
                         , email = Field.value model.email
                         , password = Field.value model.password
                         , confirmPassword = Field.value model.confirmPassword
                         }
                        )
                    )
                    ( nodeEnv, apiKey )
                )
    in
        ( model, cmd )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ div [] [ h2 [] [ text "Sign Up" ] ]
        , Html.form [ onSubmit SignUp ]
            [ div []
                [ label [] [ text "First Name: " ]
                , input
                    [ Html.Attributes.value <| Field.value model.firstName
                    , type_ "text"
                    , placeholder "First Name"
                    , onInput FirstNameInput
                    ]
                    []
                ]
            , div []
                [ label [] [ text "Email: " ]
                , input
                    [ Html.Attributes.value <| Field.value model.email
                    , type_ "text"
                    , placeholder "Email"
                    , onInput EmailInput
                    ]
                    []
                ]
            , div []
                [ label [] [ text "Password: " ]
                , input
                    [ Html.Attributes.value <| Field.value model.password
                    , type_ "password"
                    , placeholder "Password"
                    , onInput PasswordInput
                    ]
                    []
                ]
            , div []
                [ label [] [ text "Confirm Password: " ]
                , input
                    [ Html.Attributes.value <| Field.value model.confirmPassword
                    , type_ "password"
                    , placeholder "Confirm Password"
                    , onInput ConfirmPasswordInput
                    ]
                    []
                ]
            , button [ type_ "submit", class "button primary" ] [ text "Sign Up" ]
            ]
        ]
