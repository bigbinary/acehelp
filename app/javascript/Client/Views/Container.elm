module Views.Container exposing (..)

import Html exposing (..)
import Html.Attributes exposing (id, style, class, classList)
import Html.Events exposing (onClick)
import Svg
import Svg.Attributes
import Animation
import Color exposing (rgb)


questionMarkShape : String -> String -> String -> Html msg
questionMarkShape width height color =
    Svg.svg
        [ Svg.Attributes.style ("width: " ++ width ++ "px; " ++ "height: " ++ height ++ "px")
        , Svg.Attributes.viewBox ("0 0 90 90")
        ]
        [ Svg.g []
            [ Svg.path
                [ Svg.Attributes.d "M65.449,6.169C59.748,2.057,52.588,0,43.971,0c-6.559,0-12.09,1.449-16.588,4.34    C20.25,8.871,16.457,16.562,16,27.412h16.531c0-3.158,0.922-6.203,2.766-9.137c1.846-2.932,4.975-4.396,9.389-4.396    c4.488,0,7.58,1.19,9.271,3.568c1.693,2.381,2.539,5.018,2.539,7.91c0,2.513-1.262,4.816-2.781,6.91    c-0.836,1.22-1.938,2.342-3.307,3.369c0,0-8.965,5.75-12.9,10.368c-2.283,2.681-2.488,6.692-2.689,12.449    c-0.014,0.409,0.143,1.255,1.576,1.255c1.433,0,11.582,0,12.857,0s1.541-0.951,1.559-1.362c0.09-2.098,0.326-3.167,0.707-4.377    c0.723-2.286,2.688-4.283,4.893-5.997l4.551-3.141c4.107-3.199,7.385-5.826,8.83-7.883C72.264,33.562,74,29.393,74,24.443    C74,16.373,71.148,10.281,65.449,6.169z M43.705,69.617c-5.697-0.17-10.398,3.771-10.578,9.951    c-0.178,6.178,4.293,10.258,9.99,10.426c5.949,0.177,10.523-3.637,10.701-9.814C53.996,74,49.654,69.793,43.705,69.617z"
                , Svg.Attributes.fill color
                ]
                []
            ]
        ]


articleShape : String -> String -> String -> Html msg
articleShape width height color =
    Svg.svg
        [ Svg.Attributes.style ("width: " ++ width ++ "px; " ++ "height: " ++ height ++ "px")
        , Svg.Attributes.viewBox ("0 0 438.533 438.533")
        ]
        [ Svg.g []
            [ Svg.path
                [ Svg.Attributes.d "M396.283,130.188c-3.806-9.135-8.371-16.365-13.703-21.695l-89.078-89.081c-5.332-5.325-12.56-9.895-21.697-13.704    C262.672,1.903,254.297,0,246.687,0H63.953C56.341,0,49.869,2.663,44.54,7.993c-5.33,5.327-7.994,11.799-7.994,19.414v383.719    c0,7.617,2.664,14.089,7.994,19.417c5.33,5.325,11.801,7.991,19.414,7.991h310.633c7.611,0,14.079-2.666,19.407-7.991    c5.328-5.332,7.994-11.8,7.994-19.417V155.313C401.991,147.699,400.088,139.323,396.283,130.188z M255.816,38.826    c5.517,1.903,9.418,3.999,11.704,6.28l89.366,89.366c2.279,2.286,4.374,6.186,6.276,11.706H255.816V38.826z M365.449,401.991    H73.089V36.545h146.178v118.771c0,7.614,2.662,14.084,7.992,19.414c5.332,5.327,11.8,7.994,19.417,7.994h118.773V401.991z"
                , Svg.Attributes.fill color
                ]
                []
            , Svg.path
                [ Svg.Attributes.d "M319.77,292.355h-201c-2.663,0-4.853,0.855-6.567,2.566c-1.709,1.711-2.568,3.901-2.568,6.563v18.274    c0,2.67,0.856,4.859,2.568,6.57c1.715,1.711,3.905,2.567,6.567,2.567h201c2.663,0,4.854-0.856,6.564-2.567s2.566-3.9,2.566-6.57    v-18.274c0-2.662-0.855-4.853-2.566-6.563C324.619,293.214,322.429,292.355,319.77,292.355z"
                , Svg.Attributes.fill color
                ]
                []
            , Svg.path
                [ Svg.Attributes.d "M112.202,221.831c-1.709,1.712-2.568,3.901-2.568,6.571v18.271c0,2.666,0.856,4.856,2.568,6.567    c1.715,1.711,3.905,2.566,6.567,2.566h201c2.663,0,4.854-0.855,6.564-2.566s2.566-3.901,2.566-6.567v-18.271    c0-2.663-0.855-4.854-2.566-6.571c-1.715-1.709-3.905-2.564-6.564-2.564h-201C116.107,219.267,113.917,220.122,112.202,221.831z"
                , Svg.Attributes.fill color
                ]
                []
            ]
        ]


leftArrowButton : msg -> Html msg
leftArrowButton clickMsg =
    div
        [ class "arrow-left"
        , onClick <| clickMsg
        ]
        [ Svg.svg
            [ Svg.Attributes.width "50"
            , Svg.Attributes.height "80"
            , Svg.Attributes.viewBox "0 0 50 80"
            ]
            [ Svg.polyline
                [ Svg.Attributes.fill "none"
                , Svg.Attributes.stroke "#FFFFFF"
                , Svg.Attributes.strokeWidth "10"
                , Svg.Attributes.strokeLinecap "round"
                , Svg.Attributes.strokeLinejoin "round"
                , Svg.Attributes.points " 45.63,75.8 0.375,38.087 45.63,0.375 "
                ]
                []
            ]
        ]


closeButton : msg -> Html msg
closeButton clkMsg =
    div
        [ class "close-button"
        , onClick <| clkMsg
        ]
        [ Svg.svg
            [ Svg.Attributes.width "60"
            , Svg.Attributes.height "60"
            , Svg.Attributes.viewBox "0 0 60 60"
            ]
            [ Svg.path
                [ Svg.Attributes.d "M35.7,30L58.8,6.8C59.6,6.1,60,5.1,60,4c0-2.2-1.8-4-4-4c-1.1,0-2.1,0.4-2.8,1.2L30,24.3L6.8,1.2C6.1,0.4,5.1,0,4,0C1.8,0,0,1.8,0,4c0,1.1,0.4,2.1,1.2,2.8L24.3,30L1.2,53.2C0.4,53.9,0,54.9,0,56c0,2.2,1.8,4,4,4c1.1,0,2.1-0.4,2.8-1.2L30,35.7l23.2,23.2c0.7,0.7,1.7,1.2,2.8,1.2c2.2,0,4-1.8,4-4c0-1.1-0.4-2.1-1.2-2.8L35.7,30z" ]
                []
            ]
        ]


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
        div [ classList [ ( "blueThemeBG", True ), ( "row-view", True ) ] ] children


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
