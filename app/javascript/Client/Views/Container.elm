module Views.Container exposing (closeButton, leftArrowButton, topBar)

import Animation
import Html exposing (..)
import Html.Attributes exposing (class, classList, id, style)
import Html.Events exposing (onClick)
import Views.FontAwesome as FontAwesome exposing (..)


leftArrowButton : msg -> Html msg
leftArrowButton clickMsg =
    div
        [ class "back-button headerIcon"
        , onClick <| clickMsg
        ]
        [ FontAwesome.angle_left ]


closeButton : msg -> Html msg
closeButton clkMsg =
    div
        [ class "close-button headerIcon"
        , onClick <| clkMsg
        ]
        [ FontAwesome.plus ]


topBar : Bool -> msg -> msg -> Html msg
topBar showBack onBack onClose =
    let
        initialChildren =
            [ span
                [ id "top-bar-title"
                ]
                [ text "Ace Help" ]
            , closeButton onClose
            ]

        children =
            case showBack of
                True ->
                    leftArrowButton onBack :: initialChildren

                False ->
                    initialChildren
    in
    div
        [ classList [ ( "row-view", True ), ( "widgetHeader", True ) ]
        , style "background-color" "rgb(60, 170, 249)"
        , style "color" "#fff"
        ]
        children



-- popInInitialAnim : List Animation.Property
-- popInInitialAnim =
--     [ Animation.opacity 0
--     , Animation.scale 0.6
--     , Animation.shadow
--         { offsetX = 0
--         , offsetY = 0
--         , size = 20
--         , blur = 0
--         , color = rgb 153 153 153
--         }
--     ]
