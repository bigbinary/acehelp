module Page.ArticlesListPage exposing (..)

import Http
import Html exposing (..)
import Html.Attributes exposing (..)


--import Html.Events exposing (..)

import Data.ArticleData exposing (..)


--import Request.ArticleRequest exposing (..)
--import Task
-- Model


type alias Model =
    { articles : String --List ArticleSummary
    , currentArticle : Maybe Article
    , error : Maybe String
    }


initModel : Model
initModel =
    { articles = ""
    , currentArticle = Nothing
    , error = Nothing
    }


fetchArticlesList : Cmd Msg
fetchArticlesList =
    let
        url =
            "http://localhost:3000/api/v1/article?url=http://ace-invoice.com/getting-started"

        --request =
        --    Http.get url articlesDecoder
        request =
            Http.getString url

        cmd =
            Http.send ArticleLoaded request
    in
        cmd


init : ( Model, Cmd Msg )
init =
    ( initModel, fetchArticlesList )



--init :
-- Update


type Msg
    = FetchArticles
    | ArticleLoaded (Result Http.Error String)
    | LoadArticle ArticleId


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ArticleLoaded (Ok articles) ->
            ( { model | articles = articles }, Cmd.none )

        ArticleLoaded (Err err) ->
            ( { model | error = Just (toString err) }, Cmd.none )

        _ ->
            ( model, Cmd.none )



-- View


view : Model -> Html Msg
view model =
    div [ id "article_list" ] [ text model.articles ]


rows : List (Html Msg) -> Html Msg
rows articleRows =
    div
        [ style
            [ ( "padding", "20px 10px" )
            , ( "position", "relative" )
            ]
        ]
        articleRows
