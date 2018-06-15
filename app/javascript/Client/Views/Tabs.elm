module Views.Tabs exposing (..)

import Html exposing (..)
import Html.Attributes exposing (id, style, class, classList)
import Html.Events exposing (on, targetValue)
import Json.Decode


-- MODEL


type Tabs
    = SuggestedArticles
    | Library
    | ContactUs



-- UPDATE


type Msgs
    = TabSelected Tabs String


onTabSelect : (String -> msg) -> Html.Attribute msg
onTabSelect tagger =
    on "click" (Json.Decode.map tagger targetValue)



-- VIEW


tabView : List Tabs -> Html Msgs
tabView tabs =
    let
        tabsDom =
            List.map
                (\tab -> div [ class "tabs", onTabSelect (TabSelected tab) ] [ text (tabToString tab) ])
                tabs
    in
        div
            [ id "tab-group"
            , style [ ( "background-color", "rgb(60, 170, 249)" ), ( "color", "#fff" ) ]
            ]
        <|
            (span [ id "under-tab" ] [])
                :: tabsDom


tabToString : Tabs -> String
tabToString tab =
    case tab of
        SuggestedArticles ->
            "Suggested Articles"

        Library ->
            "Library"

        ContactUs ->
            "Contact Us"
