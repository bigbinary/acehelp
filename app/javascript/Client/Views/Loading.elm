module Views.Loading exposing (..)

import Html exposing (..)
import Html.Attributes as Attributes exposing (id)
import Views.Spinner exposing (..)
import Views.Style exposing (acehelpBlue)


sectionLoadingView : Html msg
sectionLoadingView =
    div
        [ id "#loading-view"
        ]
        [ div
            [ id "spinner-container"
            ]
            [ spinner acehelpBlue ]
        ]
