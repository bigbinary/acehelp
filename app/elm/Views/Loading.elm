module Views.Loading exposing (..)

import Html exposing (..)
import Html.Attributes as Attributes exposing (style)
import Views.Spinner exposing (..)
import Views.Style exposing (ahBlue)

sectionLoadingView : Html msg
sectionLoadingView =
    div [ style
            [ ( "position", "relative" )
            , ( "height", "100%" )
            ]
        ]
        [ spinner ahBlue
        ]
