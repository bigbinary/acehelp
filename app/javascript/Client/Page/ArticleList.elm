module Page.ArticleList exposing (init, initAnim, Msg(..), Model, view, noArticles)

import Data.Category exposing (CategoryId)
import Data.Article exposing (..)
import Request.Article exposing (..)
import Request.Helpers exposing (..)
import Views.Container exposing (rowView, popInInitialAnim)
import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (style)
import Animation
import Http
import Task exposing (Task)
import Reader exposing (Reader)


-- MODEL


type alias Model =
    { id : Maybe CategoryId
    , articles : List ArticleSummary
    }


noArticles : List ArticleSummary
noArticles =
    []


init : Reader ( NodeEnv, ApiKey, Context ) (Task Http.Error (List ArticleSummary))
init =
    requestArticleList


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
            (\article ->
                div
                    [ onClick <| LoadArticle article.id
                    , style [ ( "cursor", "pointer" ) ]
                    ]
                    [ text article.title ]
            )
            model.articles
        )
