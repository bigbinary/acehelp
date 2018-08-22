port module Views.Tabs exposing (Model, Msg(..), Tabs(..), init, modelWithTabs, allTabs, update, view, tabToString)

import Html exposing (..)
import Html.Attributes exposing (id, style, class, classList)
import Html.Events exposing (onClick, targetValue)
import List.Zipper as Zipper exposing (Zipper)


-- MODEL


type Tabs
    = SuggestedArticles
    | Library
    | ContactUs


type alias Model =
    Zipper Tabs


init : ( Model, Cmd Msg )
init =
    ( Zipper.singleton SuggestedArticles, Cmd.none )


modelWithTabs : List Tabs -> Model
modelWithTabs tabs =
    Zipper.fromList tabs
        |> Zipper.withDefault ContactUs


allTabs : List Tabs
allTabs =
    [ SuggestedArticles, Library, ContactUs ]



-- UPDATE


type Msg
    = TabSelected Tabs


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TabSelected newTab ->
            let
                updatedTabs =
                    Zipper.first model
                        |> Zipper.find ((==) newTab)
                        |> Zipper.withDefault ContactUs
            in
                ( updatedTabs, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    let
        currentTab =
            Zipper.current model

        tabsDom =
            Zipper.toList model
                |> List.map
                    (\tab ->
                        div
                            [ classList
                                [ ( "tabs", True )
                                , ( "selected"
                                  , (Zipper.current model) == tab
                                  )
                                ]
                            , onClick (TabSelected tab)
                            ]
                            [ text (tabToString tab)
                            ]
                    )
    in
        div
            [ id "tab-group"
            , style [ ( "background-color", "rgb(60, 170, 249)" ), ( "color", "#fff" ) ]
            ]
        <|
            (span
                [ id "under-tab"
                , class (underTabClassForTab currentTab)
                , style
                    [ ( "background-color", "#ffffff" )
                    ]
                ]
                []
            )
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


underTabClassForTab : Tabs -> String
underTabClassForTab tab =
    case tab of
        SuggestedArticles ->
            "highlight-suggested"

        Library ->
            "highlight-library"

        ContactUs ->
            "highlight-contactus"
