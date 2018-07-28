module Views.Container exposing (..)

import Html exposing (..)
import Html.Attributes exposing (id, style, class, classList)
import Html.Events exposing (onClick)
import Animation
import Color exposing (rgb)
import FontAwesome.Solid as SolidIcon


leftArrowButton : msg -> Html msg
leftArrowButton clickMsg =
    div
        [ class "back-button headerIcon"
        , onClick <| clickMsg
        ]
        [ SolidIcon.angle_left ]


closeButton : msg -> Html msg
closeButton clkMsg =
    div
        [ class "close-button headerIcon"
        , onClick <| clkMsg
        ]
        [ SolidIcon.plus ]


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
                    (leftArrowButton onBack) :: initialChildren

                False ->
                    initialChildren
    in
        div
            [ classList [ ( "row-view", True ), ( "widgetHeader", True ) ]
            , style [ ( "background-color", "rgb(60, 170, 249)" ), ( "color", "#fff" ) ]
            ]
            children


popInInitialAnim : List Animation.Property
popInInitialAnim =
    [ Animation.opacity 0
    , Animation.scale 0.6
    , Animation.shadow
        { offsetX = 0
        , offsetY = 0
        , size = 20
        , blur = 0
        , color = rgb 153 153 153
        }
    ]
