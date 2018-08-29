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
import Admin.Data.ReaderCmd exposing (..)
import Route as Route


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
            case error of
                GQLClient.HttpError err ->
                    ( { model | error = Just "Something went wrong. Please try again" }, [] )

                GQLClient.GraphQLError err ->
                    ( { model | error = Just <| String.join ". " <| List.map .message err }, [] )


signUp : Model -> ( Model, List (ReaderCmd Msg) )
signUp model =
    let
        cmd =
            Open <|
                Reader.map (Task.attempt SignUpResponse)
                    (signupRequest
                        ({ firstName = Field.value model.firstName
                         , email = Field.value model.email
                         , password = Field.value model.password
                         , confirmPassword = Field.value model.confirmPassword
                         }
                        )
                    )
    in
        ( model, [ cmd ] )



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
            , button [ type_ "submit", class "button primary", onClick ForgotPasswordRedirect ] [ text "Forgot Password" ]
            ]
        ]
