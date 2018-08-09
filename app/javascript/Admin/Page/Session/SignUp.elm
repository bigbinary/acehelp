module Page.Session.SignUp exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Task exposing (Task)
import Reader exposing (Reader)
import Field exposing (..)
import Field.ValidationResult exposing (..)
import Helpers exposing (..)
import GraphQL.Client.Http as GQLClient


-- MODEL


type alias Model =
    { firstName : Field String String
    , email : Field String String
    , password : Field String String
    , confirmPassword : Field String String
    }


initModel : Model
initModel =
    { firstName = Field (validateEmpty "First Name") ""
    , email = Field (validateEmpty "Email") ""
    , password = Field (validateEmpty "Password") ""
    , confirmPassword = Field (validateEmpty "Confirm Password") ""
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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FirstNameInput firstName ->
            ( { model | firstName = Field.update model.firstName firstName }, Cmd.none )

        EmailInput email ->
            ( { model | email = Field.update model.email email }, Cmd.none )

        PasswordInput password ->
            ( { model | password = Field.update model.password password }, Cmd.none )

        ConfirmPasswordInput password ->
            ( { model | confirmPassword = Field.update model.confirmPassword password }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ Html.form []
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
