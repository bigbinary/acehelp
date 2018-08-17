module Page.Session.ForgotPassword exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Field exposing (..)


--import Field.ValidationResult exposing (..)
--import GraphQL.Client.Http as GQLClient

import Helpers exposing (..)


--import Admin.Request.Session exposing (..)
--import Reader exposing (Reader)
--import Task exposing (Task)

import Request.Helpers exposing (..)


-- MODEL


type alias Model =
    { error : List String
    , email : Field String String
    }


init : ( Model, Cmd Msg )
init =
    ( { error = []
      , email = Field (validateEmpty "Email") ""
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = ForgotPassword
    | SetEmail String


update : Msg -> Model -> NodeEnv -> ( Model, Cmd Msg )
update msg model nodeEnv =
    case msg of
        ForgotPassword ->
            ( model, Cmd.none )

        SetEmail email ->
            ( { model | email = Field.update model.email email }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container login-container" ]
        [ Html.form []
            [ div [ class "form-group" ]
                [ label [ for "email" ] [ text "Email" ]
                , input [ Html.Attributes.value <| Field.value model.email, type_ "text", class "form-control", id "email", placeholder "Enter email", onInput SetEmail ] []
                ]
            , button [ type_ "submit", class "btn btn-primary" ] [ text "Send Reset Password Link" ]
            ]
        ]
