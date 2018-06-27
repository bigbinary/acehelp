module Section.ArticleList exposing (init, initAnim, Msg(..), Model, view, noArticles)

import Data.Category exposing (CategoryId)
import Data.Article exposing (..)
import Request.Article exposing (..)
import Request.Helpers exposing (..)
import Views.Container exposing (popInInitialAnim)
import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (id, class)
import Animation
import Http
import Task exposing (Task)
import Reader exposing (Reader)
import FontAwesome.Solid as SolidIcon


-- MODEL


type alias Model =
    { id : Maybe CategoryId
    , articles : List ArticleSummary
    }


noArticles : List ArticleSummary
noArticles =
    []


init : Reader ( NodeEnv, ApiKey, Context ) (Task Http.Error ArticleListResponse)
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
    case model.articles of
        [] ->
            div [ class "header-right" ]
            [ text "OOPS! No suggested Articles"
            ]

        _ ->
            div [ id "content-wrapper" ]
                (List.map
                    (\article ->
                        div
                            [ onClick <| LoadArticle article.id
                            , class "selectable-row"
                            ]
                            [ span [ class "row-icon" ] [ SolidIcon.file_alt ]
                            , span [ class "row-title" ] [ text article.title ]
                            ]
                    )
                    model.articles
                )
