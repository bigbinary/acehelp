module Page.ArticleList exposing (init, Msg(..), Model, view, noArticles)

import Data.Article exposing (..)
import Request.Article exposing (..)
import Views.Container exposing (rowView)
import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (style)
import Http
import Task
import Animation
import Color exposing (grey, rgb)


-- MODEL


type alias Model =
    List ArticleShort


noArticles : List ArticleShort
noArticles =
    []


init : Task.Task Http.Error (List ArticleShort)
init =
    Http.toTask requestArticleList


initAnim : List Animation.Property
initAnim =
    [ Animation.opacity 0
    , Animation.scale 0.6
    , Animation.shadow
        { offsetX = 0
        , offsetY = 0
        , size = 20
        , blur = 0
        , color = rgb 153 153 153
        }
    ]



-- UPDATE


type Msg
    = LoadArticle ArticleId


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        _ ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    rowView []
        (List.map
            (\a ->
                div [ onClick <| LoadArticle a.id
                    , style [("cursor", "pointer")]
                    ] [ text a.title ]
            )
            model
        )
