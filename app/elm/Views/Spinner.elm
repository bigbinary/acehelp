module Views.Spinner exposing (..)

import Html exposing (..)
import Html.Attributes as Attributes exposing (class)
import Color exposing (Color)
import Css exposing (..)
import Css.Foreign exposing (global, class, descendants, div)
import Html.Styled

-- TODO: use style-elements
spinner : Color.Color -> Html msg
spinner color =
    Html.div [Attributes.class "ah-spinner"]
        [ Html.div [Attributes.class "rect1"] []
        , Html.div [Attributes.class "rect2"] []
        , Html.div [Attributes.class "rect3"] []
        , Html.div [Attributes.class "rect4"] []
        , Html.div [Attributes.class "rect5"] []
        ]