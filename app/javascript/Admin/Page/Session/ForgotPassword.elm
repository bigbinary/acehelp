module Page.Session.ForgotPassword exposing (Model, Msg(..), init, initModel, update, view)

import Admin.Data.ReaderCmd exposing (..)
import Admin.Request.Session exposing (..)
import Field exposing (..)
import Field.ValidationResult exposing (..)
import GraphQL.Client.Http as GQLClient
import Helpers exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Reader exposing (Reader)
import Request.Helpers exposing (..)
import Task exposing (Task)



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


init : ( Model, List (ReaderCmd Msg) )
init =
    ( initModel, [] )



-- UPDATE


type Msg
    = ForgotPassword
    | SetEmail String
    | SendResetPasswordLink
    | SendResetPasswordLinkResponse (Result GQLClient.Error String)


update : Msg -> Model -> ( Model, List (ReaderCmd Msg) )
update msg model =
    case msg of
        ForgotPassword ->
            ( model, [] )

        SetEmail email ->
            ( { model | email = Field.update model.email email }, [] )

        SendResetPasswordLinkResponse (Ok response) ->
            ( { model | email = Field.update model.email "" }, [] )

        SendResetPasswordLinkResponse (Err err) ->
            ( model, [] )

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
                            [ Open <|
                                Reader.map
                                    (Task.attempt SendResetPasswordLinkResponse)
                                    (requestResetPassword
                                        { email = Field.value model.email }
                                    )
                            ]

                        False ->
                            []
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
