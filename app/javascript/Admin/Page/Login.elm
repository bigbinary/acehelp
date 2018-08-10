module Page.Login exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Field exposing (..)
import Field.ValidationResult exposing (..)
import Helpers exposing (..)


-- MODEL


type alias Model =
    { error : List String
    , username : Field String String
    , password : Field String String
    }


init =
    ({ error = []
     , username = Field (validateEmpty "Username") ""
     , password = Field (validateEmpty "Password") ""
     }
    )



-- UPDATE


type Msg
    = Login
    | ForgotPassword
    | Signup
    | SetUsername String
    | SetPassword String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Login ->
            ( model, Cmd.none )

        ForgotPassword ->
            ( model, Cmd.none )

        Signup ->
            ( model, Cmd.none )

        SetUsername username ->
            ( model, Cmd.none )

        SetPassword password ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container login-container" ]
        [ Html.form []
            [ div [ class "form-group" ]
                [ label [ for "username" ] [ text "Username" ]
                , input [ type_ "text", class "form-control", id "username", placeholder "Enter email", onInput SetUsername ] []
                ]
            , div [ class "form-group" ]
                [ label [ for "password" ] [ text "Password" ]
                , input [ type_ "password", class "form-control", id "password", placeholder "Password", onInput SetPassword ] []
                ]
            , button [ type_ "submit", class "btn btn-primary", onClick Login ] [ text "Login" ]
            ]
        ]
