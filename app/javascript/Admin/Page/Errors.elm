module Page.Errors exposing (errorAlertView, notFound)

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


errorAlertView : List String -> Html msg
errorAlertView errors =
    case errors of
        [] ->
            text ""

        _ ->
            div [ class "alert alert-danger alert-dismissible fade show", attribute "role" "alert" ]
                [ text <| (++) "Error: " <| String.join ", " errors ]
