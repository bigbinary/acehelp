module Page.CategoryList exposing (init, initAnim, Msg(..), Model, view, noArticles)

import Data.Category exposing (..)
import Data.Article exposing (..)
import Request.Category exposing (..)
import Views.Container exposing (rowView, popInInitialAnim)
import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (style)
import Http
import Task
import Animation


-- MODEL


type alias Model =
    List Category


noArticles : List Category
noArticles =
    []


init : Task.Task Http.Error Categories
init =
    Http.toTask requestCategories


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
        -- (List.map
        --     (\a ->
        --         div [ onClick <| LoadArticle a.id
        --             , style [("cursor", "pointer")]
        --             ] [ text a.title ]
        --     )
        --     model
        -- )
        []
