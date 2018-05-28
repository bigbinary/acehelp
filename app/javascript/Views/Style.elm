module Views.Style exposing (..)

import Element
import Element.Attributes
import Animation
import Style exposing (..)
import Style.Font as Font
import Style.Color as Color
import Style.Shadow as Shadow
import Style.Border as Border
import Color exposing (..)


-- Experimental stuff with style-elements and elm-style-animations


type AHStyle
    = AHButton
    | MainContainerStyle
    | StackStyle
    | NavigationStyle
    | SearchStyle
    | ArticleListStyle
    | ArticleStyle ArticleStyles
    | FooterStyle


type ArticleStyles
    = Header
    | Body


defaultFont : Property class variation
defaultFont =
    Font.typeface
        [ Font.font "proxima-nova"
        , Font.font "Arial"
        , Font.font "sans-serif"
        ]


stylesheet : StyleSheet AHStyle variation
stylesheet =
    Style.styleSheet
        [ style AHButton
            [ defaultFont
            , Color.background lightBlue
            , Border.rounded 50
            , Font.size 80
            , Font.center
            , Color.text white
            ]
        , style MainContainerStyle
            [ defaultFont
            , Color.background white
            , Shadow.box
                { offset = ( 0, 0 )
                , size = 15
                , blur = 50
                , color = Color.rgb 153 153 153
                }
            , Style.opacity 0.0
            ]

        --  TODO: Add other styles
        ]


renderAnim : Animation.State -> List (Element.Attribute variation msg) -> List (Element.Attribute variation msg)
renderAnim animStyle otherAttrs =
    (List.map Element.Attributes.toAttr <| Animation.render animStyle) ++ otherAttrs
