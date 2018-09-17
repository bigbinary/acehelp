module Views.Loading exposing (sectionLoadingView)

import Html exposing (..)
import Html.Attributes as Attributes exposing (id)
import Views.Spinner exposing (..)


sectionLoadingView : Html msg
sectionLoadingView =
    div
        [ id "#loading-view"
        ]
        [ div
            [ id "spinner-container"
            ]
            [ spinner "rgb(60, 170, 249)" ]
        ]
