module Page.ArticleList exposing (init, initAnim, Msg(..), Model, view, noArticles)

import Data.Article exposing (..)
import Request.Article exposing (..)
import Views.Container exposing (rowView, popInInitialAnim)
import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (style)
import Http
import Task
import Animation


-- MODEL


type alias Model =
    List ArticleSummary


noArticles : List ArticleSummary
noArticles =
    []


init : Task.Task Http.Error (List ArticleSummary)
init =
    Http.toTask requestArticleList


initAnim : Animation.State
initAnim =
    Animation.style popInInitialAnim



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
                div
                    [ onClick <| LoadArticle a.id
                    , style [ ( "cursor", "pointer" ) ]
                    ]
                    [ text a.title ]
            )
            model
        )
