module Page.Common.View exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Json.Decode as Json
import Admin.Data.Common exposing (..)


renderError : Maybe String -> String
renderError error =
    if (error == Nothing) then
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
    div [ class "loading-indicator" ] [ text msg, spinner ]


spinner : Html msg
spinner =
    div [ Attributes.class "spinner" ]
        [ div [ Attributes.class "rect rect1" ] []
        , div [ Attributes.class "rect rect2" ] []
        , div [ Attributes.class "rect rect3" ] []
        , div [ Attributes.class "rect rect4" ] []
        , div [ Attributes.class "rect rect5" ] []
        ]
