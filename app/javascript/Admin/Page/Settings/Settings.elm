module Page.Settings.Settings exposing (Model, Msg(..), SubPage(..), init, initModel, update, view)

import Admin.Data.ReaderCmd exposing (..)
import Admin.Request.Helper exposing (ApiKey, AppUrl, NodeEnv, baseUrl)
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Settings.Widget as Widget


-- Model


type alias Model =
    { currentSubPage : SubPage
    }


type SubPage
    = Widget Widget.Model


initModel : Model
initModel =
    { currentSubPage = Widget Widget.initModel
    }


init : ( Model, List (ReaderCmd Msg) )
init =
    ( initModel
    , []
    )



-- Update


type Msg
    = SubMenuClicked
    | WidgetMsg Widget.Msg


update : Msg -> Model -> ( Model, List (ReaderCmd Msg) )
update msg model =
    ( model, [] )



-- View


view : NodeEnv -> ApiKey -> AppUrl -> Model -> Html Msg
view nodeEnv organizationKey appUrl model =
    case model.currentSubPage of
        Widget subModel ->
            Html.map WidgetMsg <| Widget.view nodeEnv organizationKey appUrl subModel
