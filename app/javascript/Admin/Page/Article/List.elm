module Page.Article.List exposing (..)

import Http
import Html exposing (..)
import Html.Attributes exposing (..)
import Request.ArticleRequest exposing (..)


--import Html.Events exposing (..)

import Data.ArticleData exposing (..)


-- Model


type alias Model =
    { articles : ArticleListResponse
    , error : Maybe String
    }


initModel : Model
initModel =
    { articles = { articles = [] }
    , error = Nothing
    }


init : ( Model, Cmd Msg )
init =
    ( initModel, fetchArticlesList )



-- Update


type Msg
    = FetchArticles
    | ArticleLoaded (Result Http.Error ArticleListResponse)
    | LoadArticle ArticleId


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ArticleLoaded (Ok articlesList) ->
            ( { model | articles = articlesList }, Cmd.none )

        ArticleLoaded (Err err) ->
            ( { model | error = Just (toString err) }, Cmd.none )

        _ ->
            ( model, Cmd.none )



-- View


view : Model -> Html Msg
view model =
    div
        [ id "article_list"
        ]
        [ div
            [ class "buttonDiv" ]
            [ a
                [ href "/admin/articles/new"
                , class "button primary"
                ]
                [ text "New Article" ]
            ]
        , div
            []
            (List.map
                (\article ->
                    rows article
                )
                model.articles.articles
            )
        ]


rows : Article -> Html Msg
rows article =
    div
        []
        [ text article.title
        ]


fetchArticlesList : Cmd Msg
fetchArticlesList =
    let
        request =
            requestArticles "dev" "http://ace-invoice.com/getting-started" "3c60b69a34f8cdfc76a0"

        cmd =
            Http.send ArticleLoaded request
    in
        cmd
