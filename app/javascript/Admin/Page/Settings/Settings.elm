module Page.Settings.Settings exposing
    ( Model
    , Msg(..)
    , SubPage(..)
    , init
    , initModel
    , update
    , view
    )

import Admin.Data.ReaderCmd as ReaderCmd exposing (..)
import Admin.Request.Helper exposing (ApiKey, AppUrl, NodeEnv, baseUrl)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Page.Settings.General as General
import Page.Settings.Widget as Widget



-- Model


type alias Model =
    { currentPosition : MenuPosition
    , currentSubPage : SubPage
    }


type SubPage
    = Widget Widget.Model


type MenuPosition
    = MenuWidget
    | MenuSettings


initModel : Model
initModel =
    { currentPosition = MenuWidget, currentSubPage = Widget Widget.initModel }


init : ( Model, List (ReaderCmd Msg) )
init =
    ( initModel
    , []
    )



-- Update


type Msg
    = SubMenuClicked MenuPosition
    | WidgetMsg Widget.Msg


update : Msg -> Model -> ( Model, List (ReaderCmd Msg) )
update msg model =
    case msg of
        WidgetMsg menuMsg ->
            let
                subModel =
                    case model.currentSubPage of
                        Widget widgetModel ->
                            widgetModel
            in
            Widget.update menuMsg subModel
                |> mapSubViewUpdate model Widget WidgetMsg

        SubMenuClicked newModel ->
            ( model, [] )


mapSubViewUpdate model modelMap msgMap ( subPageModel, subCmd ) =
    ( { model | currentSubPage = modelMap <| subPageModel }
    , List.map
        (ReaderCmd.map <|
            Cmd.map
                msgMap
        )
        subCmd
    )



-- View


view : NodeEnv -> ApiKey -> AppUrl -> Model -> Html Msg
view nodeEnv organizationKey appUrl model =
    let
        contentView =
            case model.currentSubPage of
                Widget subModel ->
                    Html.map WidgetMsg <| Widget.view nodeEnv organizationKey appUrl subModel
    in
    div [ class "container" ]
        [ div [ class "row" ] [ div [ class "col-md-2" ] [ menuView model ], div [ class "col" ] [ contentView ] ] ]


menuView model =
    div []
        [ nav [ class "nav flex-column" ]
            [ a [ href "#", classList [ ( "nav-link", True ), ( "active", model.currentPosition == MenuWidget ) ], onClick <| SubMenuClicked MenuWidget ] [ text "Widget" ]
            , a [ href "#", classList [ ( "nav-link", True ), ( "active", False ) ] ] [ text "Settings" ]
            ]
        ]
