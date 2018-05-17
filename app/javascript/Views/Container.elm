module Views.Container exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style)

rowView : List (Html msg) -> Html msg
rowView children =
    div [ style
            [( "padding", "20px 10px")]
        ] children