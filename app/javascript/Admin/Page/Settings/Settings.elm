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
    | General General.Model


type MenuPosition
    = MenuWidget
    | MenuGeneral


initModel : Model
initModel =
    { currentPosition = MenuWidget, currentSubPage = Widget Widget.initModel }


init : ( Model, List (ReaderCmd Msg) )
init =
    Widget.init
        |> mapSubViewUpdate initModel Widget WidgetMsg



-- Update


type Msg
    = SubMenuClicked MenuPosition
    | WidgetMsg Widget.Msg
    | GeneralMsg General.Msg


update : Msg -> Model -> ( Model, List (ReaderCmd Msg) )
update msg model =
    case msg of
        WidgetMsg menuMsg ->
            case model.currentSubPage of
                Widget widgetModel ->
                    Widget.update menuMsg widgetModel
                        |> mapSubViewUpdate model Widget WidgetMsg

                _ ->
                    ( model, [] )

        GeneralMsg menuMsg ->
            case model.currentSubPage of
                General generalModel ->
                    General.update menuMsg generalModel
                        |> mapSubViewUpdate model General GeneralMsg

                _ ->
                    ( model, [] )

        SubMenuClicked menuPosition ->
            case menuPosition of
                MenuWidget ->
                    Widget.init
                        |> mapSubViewUpdate model Widget WidgetMsg

                MenuGeneral ->
                    General.init
                        |> mapSubViewUpdate model General GeneralMsg


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

                General subModel ->
                    Html.map GeneralMsg <| General.view nodeEnv organizationKey appUrl subModel
    in
    div [ class "container" ]
        [ div [ class "row" ] [ div [ class "col-md-2" ] [ menuView model ], div [ class "col" ] [ contentView ] ] ]


menuView model =
    div []
        [ nav [ class "nav flex-column" ]
            [ a
                [ href "#"
                , classList [ ( "nav-link", True ), ( "active", model.currentPosition == MenuWidget ) ]
                , onClick <| SubMenuClicked MenuWidget
                ]
                [ text "Widget" ]
            , a
                [ href "#"
                , classList [ ( "nav-link", True ), ( "active", model.currentPosition == MenuGeneral ) ]
                , onClick <| SubMenuClicked MenuGeneral
                ]
                [ text "General" ]
            ]
        ]
