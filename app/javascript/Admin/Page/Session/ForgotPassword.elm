module Page.Session.ForgotPassword exposing (..)

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
    , email : Field String String
    }


initModel : Model
initModel =
    { error = []
    , email = Field (validateEmpty "Email") ""
    }


init : ( Model, Cmd Msg )
init =
    ( initModel, Cmd.none )



-- UPDATE


type Msg
    = ForgotPassword
    | SetEmail String
    | SendResetPasswordLink
    | SendResetPasswordLinkResponse (Result GQLClient.Error String)


update : Msg -> Model -> NodeEnv -> ( Model, Cmd Msg )
update msg model nodeEnv =
    case msg of
        ForgotPassword ->
            ( model, Cmd.none )

        SetEmail email ->
            ( { model | email = Field.update model.email email }, Cmd.none )

        SendResetPasswordLinkResponse (Ok response) ->
            ( { model | email = Field.update model.email "" }, Cmd.none )

        SendResetPasswordLinkResponse (Err err) ->
            ( model, Cmd.none )

        SendResetPasswordLink ->
            let
                error =
                    validateAll [ model.email ]
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
                    case isAllValid [ model.email ] of
                        True ->
                            Task.attempt SendResetPasswordLinkResponse
                                (Reader.run
                                    (requestResetPassword { email = Field.value model.email })
                                    nodeEnv
                                )

                        False ->
                            Cmd.none
            in
                ( { model | error = error }, cmd )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container login-container" ]
        [ Html.form [ onSubmit SendResetPasswordLink ]
            [ div [ class "form-group" ]
                [ label [ for "email" ] [ text "Email" ]
                , input
                    [ Html.Attributes.value <| Field.value model.email
                    , type_ "text"
                    , class "form-control"
                    , id "email"
                    , placeholder "Enter email"
                    , onInput SetEmail
                    ]
                    []
                ]
            , button [ type_ "submit", class "btn btn-primary" ] [ text "Send Reset Password Link" ]
            ]
        ]
