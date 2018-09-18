module Page.Session.ForgotPassword exposing (Model, Msg(..), init, initModel, update, view)

import Admin.Data.ReaderCmd exposing (..)
import Admin.Data.Session exposing (..)
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
import Route exposing (..)
import Task exposing (Task)



-- MODEL


type alias Model =
    { error : List String
    , success : List String
    , email : Field String String
    }


initModel : Model
initModel =
    { error = []
    , success = []
    , email = Field validateEmail ""
    }


init : ( Model, List (ReaderCmd Msg) )
init =
    ( initModel, [] )



-- UPDATE


type Msg
    = ForgotPassword
    | SetEmail String
    | SendResetPasswordLink
    | SendResetPasswordLinkResponse (Result GQLClient.Error ForgotPasswordResponse)


update : Msg -> Model -> ( Model, List (ReaderCmd Msg) )
update msg model =
    case msg of
        ForgotPassword ->
            ( model, [] )

        SetEmail email ->
            ( { model | email = Field.update model.email email }, [] )

        SendResetPasswordLinkResponse (Ok response) ->
            case response.errors of
                Just errors ->
                    ( { model | email = Field.update model.email "", error = List.map .message errors }, [] )

                Nothing ->
                    ( { model | email = Field.update model.email "", success = [ "Please check your email. We have sent a link to reset your password" ] }, [] )

        SendResetPasswordLinkResponse (Err err) ->
            ( { model | error = [ "Uh oh. Something went wrong. Please try again" ] }, [] )

        SendResetPasswordLink ->
            case validate model.email of
                Passed _ ->
                    ( { model | error = [], success = [] }
                    , [ Open <|
                            Reader.map
                                (Task.attempt SendResetPasswordLinkResponse)
                                (requestResetPassword
                                    { email = Field.value model.email }
                                )
                      ]
                    )

                Failed er ->
                    ( { model | error = [ er ] }, [] )



-- VIEW


view : Model -> Html Msg
view model =
    div
        [ class "page-wrap" ]
        [ div [ class "container login-container" ]
            [ div [ class "page-content row" ]
                [ div [ class "col-md-12" ]
                    [ h3 [ class "form-header" ] [ text "Reset password" ]
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
                    , case model.success of
                        [] ->
                            text ""

                        _ ->
                            div []
                                [ div
                                    [ class "alert alert-success"
                                    ]
                                    (List.map
                                        (\er -> div [] [ text er ])
                                        model.success
                                    )
                                ]
                    , div []
                        [ div [ class "form-group" ]
                            [ label [ for "email" ] [ text "Email" ]
                            , input
                                [ Html.Attributes.value <| Field.value model.email
                                , type_ "text"
                                , class "form-control"
                                , id "email"
                                , placeholder "Enter your email id"
                                , onInput SetEmail
                                ]
                                []
                            ]
                        ]
                    , div [ class "form-section" ]
                        [ button [ onClick SendResetPasswordLink, class "btn btn-primary" ] [ text "Send Reset Password Link" ]
                        ]
                    ]
                , div [ class "links-section col-md-12" ]
                    [ span [ class "btn" ]
                        [ a
                            [ href <| routeToString <| SignUp ]
                            [ span [] [ text "Sign Up" ] ]
                        ]
                    , span [ class "btn" ]
                        [ a
                            [ href <| routeToString <| Login ]
                            [ span [] [ text "Sign In" ] ]
                        ]
                    ]
                ]
            ]
        ]
