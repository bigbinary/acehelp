module Page.UrlListPage exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)


--import
-- MODEL


type alias Model =
    { listOfUrls : List Url
    , urlId : UrlId
    }


type alias Url =
    { url : String
    , urlTitle : String
    }


type alias UrlId =
    Int


init : ( Model, Cmd Msg )
init =
    ( { listOfUrls = [], urlId = 0 }
    , Cmd.none
    )



-- UPDATE


type Msg
    = LoadUrl UrlId


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadUrl urlId ->
            ( { model | urlId = urlId }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div
        []
        [ div
            [ style [ ( "float", "right" ) ] ]
            [ a
                [ href "/admin/urls/new"
                , class "button primary"
                ]
                [ text "New Url"
                ]
            ]
        , text "Url List Page"
        ]
