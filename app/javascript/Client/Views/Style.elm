module Views.Style exposing (..)

import Color exposing (..)
import Svg
import Svg.Attributes


acehelpGrey : Color
acehelpGrey =
    Color.rgb 153 153 153


acehelpBlue : Color
acehelpBlue =
    Color.rgb 60 170 249


tickShape : String -> String -> Svg.Svg msg
tickShape width height =
    Svg.svg
        [ Svg.Attributes.style ("width: " ++ width ++ "px; " ++ "height: " ++ height ++ "px")
        , Svg.Attributes.viewBox ("0 0 507.2 507.2")
        ]
        [ Svg.circle
            [ Svg.Attributes.fill "#32BA7C"
            , Svg.Attributes.cx "253.6"
            , Svg.Attributes.cy "253.6"
            , Svg.Attributes.r "253.6"
            ]
            []
        , Svg.path
            [ Svg.Attributes.fill "#0AA06E"
            , Svg.Attributes.d "M188.8,368l130.4,130.4c108-28.8,188-127.2,188-244.8c0-2.4,0-4.8,0-7.2L404.8,152L188.8,368z"
            ]
            []
        , Svg.g []
            [ Svg.path
                [ Svg.Attributes.d "M260,310.4c11.2,11.2,11.2,30.4,0,41.6l-23.2,23.2c-11.2,11.2-30.4,11.2-41.6,0L93.6,272.8 c-11.2-11.2-11.2-30.4,0-41.6l23.2-23.2c11.2-11.2,30.4-11.2,41.6,0L260,310.4z"
                , Svg.Attributes.fill "#FFFFFF"
                ]
                []
            , Svg.path
                [ Svg.Attributes.d "M348.8,133.6c11.2-11.2,30.4-11.2,41.6,0l23.2,23.2c11.2,11.2,11.2,30.4,0,41.6l-176,175.2 c-11.2,11.2-30.4,11.2-41.6,0l-23.2-23.2c-11.2-11.2-11.2-30.4,0-41.6L348.8,133.6z"
                , Svg.Attributes.fill "#FFFFFF"
                ]
                []
            ]
        ]
