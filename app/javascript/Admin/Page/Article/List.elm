module Page.Article.List exposing (..)

import Http
import Html exposing (..)
import Html.Attributes exposing (..)
import Request.ArticleRequest exposing (..)
import Data.CommonData exposing (..)
import Page.Common.View exposing (renderError)
import Data.ArticleData exposing (..)


-- Model


type alias Model =
    { articles : ArticleListResponse
    , error : Error
    }


initModel : Model
initModel =
    { articles = { articles = [] }
    , error = Nothing
    }


init : String -> String -> String -> ( Model, Cmd Msg )
init env url key =
    ( initModel, fetchArticlesList env url key )



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
            []
            [ text (renderError model.error) ]
        , div
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


fetchArticlesList : String -> String -> String -> Cmd Msg
fetchArticlesList nodeEnv url organizationKey =
    let
        request =
            requestArticles nodeEnv url organizationKey

        cmd =
            Http.send ArticleLoaded request
    in
        cmd
