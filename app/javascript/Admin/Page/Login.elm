module Page.Login exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


-- MODEL
-- UPDATE


type Msg
    = Login
    | Forgot



-- VIEW


view : Html Msg
view =
    div [ class "container login-container" ]
        [ Html.form []
            [ div [ class "form-group" ]
                [ label [ for "username" ] [ text "Username" ]
                , input [ type_ "text", class "form-control", id "username", placeholder "Enter email" ] []
                ]
            , div [ class "form-group" ]
                [ label [ for "password" ] [ text "Password" ]
                , input [ type_ "password", class "form-control", id "password", placeholder "Password" ] []
                ]
            , button [ type_ "submit", class "btn btn-primary" ] [ text "Login" ]
            ]
        ]
