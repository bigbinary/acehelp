module Admin.Views.Common exposing
    ( dialogConfig
    , errorView
    , loadingIndicator
    , multiSelectMenu
    , renderError
    , spinner
    , successView
    )

import Admin.Data.Common exposing (..)
import Dialog
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


multiSelectMenu : String -> List (Option Value) -> (Option String -> msg) -> Html msg
multiSelectMenu title values onselect =
    div []
        [ h5 [] [ text title ]
        , div [ class "multi-select" ] <|
            List.map
                (\value ->
                    case value of
                        Selected valueItem ->
                            div [ class "checkbox" ]
                                [ input
                                    [ type_ "checkbox"
                                    , Html.Attributes.value valueItem.id
                                    , checked True
                                    , onClick (onselect (Unselected valueItem.id))
                                    , id valueItem.id
                                    ]
                                    []
                                , label
                                    [ for valueItem.id ]
                                    [ text valueItem.value ]
                                ]

                        Unselected valueItem ->
                            div [ class "checkbox" ]
                                [ input
                                    [ type_ "checkbox"
                                    , Html.Attributes.value valueItem.id
                                    , selected False
                                    , onClick (onselect (Selected valueItem.id))
                                    , id valueItem.id
                                    ]
                                    []
                                , label [ for valueItem.id ] [ text valueItem.value ]
                                ]
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


errorView : List String -> Html msg
errorView errors =
    case errors of
        [] ->
            text ""

        _ ->
            div [ class "alert alert-danger alert-dismissible fade show", attribute "role" "alert" ]
                [ text <| (++) "Error: " <| String.join ", " errors ]


successView : Maybe String -> Html msg
successView success =
    Maybe.withDefault (text "") <|
        Maybe.map
            (\message ->
                div [ class "alert alert-success alert-dismissible fade show", attribute "role" "alert" ]
                    [ text <| message
                    ]
            )
            success


dialogConfig : { onAccept : msg, onDecline : msg, title : String, body : String } -> Dialog.Config msg
dialogConfig model =
    { closeMessage = Just model.onDecline
    , containerClass = Nothing
    , header = Just (div [ class "modal-title" ] [ h5 [] [ text model.title ] ])
    , body = Just (text model.body)
    , footer =
        Just
            (button
                [ class "btn btn-success"
                , onClick <| model.onAccept
                ]
                [ text "Yes" ]
            )
    }
