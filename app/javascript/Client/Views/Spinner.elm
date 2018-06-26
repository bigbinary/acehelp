module Views.Spinner exposing (..)

import Html exposing (..)
import Html.Attributes as Attributes exposing (class, style)


spinner : String -> Html msg
spinner color =
    Html.div [ Attributes.class "ah-spinner" ]
        [ Html.div [ Attributes.class "rect rect1", style [ ( "background-color", color ) ] ] []
        , Html.div [ Attributes.class "rect rect2", style [ ( "background-color", color ) ] ] []
        , Html.div [ Attributes.class "rect rect3", style [ ( "background-color", color ) ] ] []
        , Html.div [ Attributes.class "rect rect4", style [ ( "background-color", color ) ] ] []
        , Html.div [ Attributes.class "rect rect5", style [ ( "background-color", color ) ] ] []
        ]
