module Views.Search exposing (..)

import Html exposing (..)
import Html.Attributes as Attributes exposing (class, style, type_)
import Color exposing (Color)
import Color.Convert exposing (colorToCssRgb)
import FontAwesome.Solid as SolidIcon


searchBar : String -> Html msg
searchBar color =
    div [ class "ah-search-bar", style [ ( "background-color", color ) ] ]
        [ input [ type_ "text" ] []
        , SolidIcon.search
        ]
