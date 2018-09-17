module Page.Errors exposing (notFound)

import Html exposing (..)
import Html.Attributes exposing (..)


notFound : Html msg
notFound =
    div [ id "something-went-wrong" ]
        [ div [ class "error" ] []
        , div
            [ class "text boldExclamationText" ]
            [ text "OOPS!" ]
        , div
            [ class "text friendlyMessage" ]
            [ text "Page you are looking for does not exists" ]
        ]
