module Page.Error exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)


-- Note: Modified version of https://codepen.io/sqfreakz/pen/GJRJOY


view : Html msg
view =
    div [ id "something-went-wrong" ]
        [ div [ id "clouds" ]
            [ div [ class "cloud x1" ] []
            , div [ class "cloud x1_5" ] []
            , div [ class "cloud x2" ] []
            , div [ class "cloud x3" ] []
            ]
        , div [ class "c" ]
            [ div [ class "_404" ] [ text "404" ]
            , hr [] []
            , div [ class "_1" ] [ text "THE PAGE" ]
            , div [ class "_2" ] [ text "WAS NOT FOUND" ]
            , a [ class "btn" ] [ text "BACK TO MARS" ]
            ]
        ]
