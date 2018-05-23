module Views.Container exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Svg
import Svg.Attributes
import Animation
import Color exposing (rgb)


rowView : List ( String, String ) -> List (Html msg) -> Html msg
rowView aStyle children =
    div
        [ style
            ([ ( "padding", "20px 10px" ), ( "position", "relative" ) ] ++ aStyle)
        ]
        children


closeButton : msg -> Html msg
closeButton clkMsg =
    div
        [ style
            [ ( "position", "absolute" )
            , ( "top", "0" )
            , ( "bottom", "0" )
            , ( "right", "35px" )
            , ( "line-height", "0" )
            ]
        , onClick <| clkMsg
        ]
        [ Svg.svg
            [ Svg.Attributes.width "60"
            , Svg.Attributes.height "60"
            , Svg.Attributes.viewBox "0 0 60 60"

            -- This is so badly inconsistent with Html style
            , Svg.Attributes.style "width: 20px; height: 20px; fill: #fff; position: absolute; top: 50%; transform: translateY(-50%);"
            ]
            [ Svg.path
                [ Svg.Attributes.d "M35.7,30L58.8,6.8C59.6,6.1,60,5.1,60,4c0-2.2-1.8-4-4-4c-1.1,0-2.1,0.4-2.8,1.2L30,24.3L6.8,1.2C6.1,0.4,5.1,0,4,0C1.8,0,0,1.8,0,4c0,1.1,0.4,2.1,1.2,2.8L24.3,30L1.2,53.2C0.4,53.9,0,54.9,0,56c0,2.2,1.8,4,4,4c1.1,0,2.1-0.4,2.8-1.2L30,35.7l23.2,23.2c0.7,0.7,1.7,1.2,2.8,1.2c2.2,0,4-1.8,4-4c0-1.1-0.4-2.1-1.2-2.8L35.7,30z" ]
                []
            ]
        ]


topBar : msg -> Html msg
topBar onClose =
    rowView [ ( "background-color", "rgb(60, 170, 249)" ) ]
        [ span
            [ style
                [ ( "text-align", "center" )
                , ( "display", "block" )
                , ( "color", "#fff" )
                ]
            ]
            [ text "Ace Help" ]
        , closeButton onClose
        ]


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