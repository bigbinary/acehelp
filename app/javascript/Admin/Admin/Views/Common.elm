module Admin.Views.Common exposing (loadingIndicator, multiSelectMenu, renderError, spinner)

import Admin.Data.Common exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json


renderError : Maybe String -> String
renderError error =
    if error == Nothing then
        ""

    else
        Maybe.withDefault "" <| Maybe.map ((++) "Error : ") error


multiSelectMenu : String -> List (Option Value) -> (List String -> msg) -> Html msg
multiSelectMenu title values onselect =
    div []
        [ h6 [] [ text title ]
        , select [ on "change" (Json.map onselect targetSelectedOptions), multiple True, class "form-control select-checkbox", size 5 ] <|
            List.map
                (\value ->
                    case value of
                        Selected valueItem ->
                            option [ Html.Attributes.value valueItem.id, selected True ] [ text valueItem.value ]

                        Unselected valueItem ->
                            option [ Html.Attributes.value valueItem.id, selected False ] [ text valueItem.value ]
                )
                values
        ]


loadingIndicator : String -> Html msg
loadingIndicator msg =
    div [ class "loading-indicator" ] [ span [ class "spinner-label" ] [ text msg ], spinner ]


spinner : Html msg
spinner =
    div [ class "spinner" ]
        [ div [ class "rect rect1" ] []
        , div [ class "rect rect2" ] []
        , div [ class "rect rect3" ] []
        , div [ class "rect rect4" ] []
        , div [ class "rect rect5" ] []
        ]
