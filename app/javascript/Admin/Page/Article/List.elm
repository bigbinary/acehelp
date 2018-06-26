module Page.Article.List exposing (..)

import Http
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Request.ArticleRequest exposing (..)
import Request.UrlRequest exposing (..)
import Data.CommonData exposing (..)
import Page.Common.View exposing (renderError)
import Data.ArticleData exposing (..)
import Data.UrlData exposing (..)
import Json.Decode as Json


-- Model


type alias Model =
    { articles : ArticleListResponse
    , urlList : UrlsListResponse
    , url : String
    , error : Error
    }


initModel : Model
initModel =
    { articles = { articles = [] }
    , urlList = { urls = [] }
    , url = ""
    , error = Nothing
    }


init : String -> String -> ( Model, Cmd Msg )
init env key =
    ( initModel, fetchUrlList env key )



-- Update


type Msg
    = UrlSelected String
    | UrlLoaded (Result Http.Error UrlsListResponse)
    | ArticleLoaded (Result Http.Error ArticleListResponse)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ArticleLoaded (Ok articlesList) ->
            ( { model | articles = articlesList }, Cmd.none )

        ArticleLoaded (Err err) ->
            ( { model | error = Just (toString err) }, Cmd.none )

        UrlLoaded (Ok urlList) ->
            ( { model | urlList = urlList }, Cmd.none )

        UrlLoaded (Err err) ->
            ( { model | error = Just (toString err) }, Cmd.none )

        UrlSelected url ->
            ( { model | url = url }, Cmd.none )



-- View


view : Model -> Html Msg
view model =
    div
        [ id "article_list"
        ]
        [ div
            []
            [ text (renderError model.error) ]
        , div []
            [ urlsDropdown model ]
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


urlsDropdown : Model -> Html Msg
urlsDropdown model =
    div
        [ class "dropdown" ]
        [ select
            [ on "change" (Json.map UrlSelected targetValue) ]
            (List.concat
                [ [ option
                        [ value "Select URL" ]
                        [ text "Select URL" ]
                  ]
                , (List.map
                    (\url ->
                        option
                            [ value url.url ]
                            [ text url.url ]
                    )
                    model.urlList.urls
                  )
                ]
            )
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


fetchUrlList : String -> String -> Cmd Msg
fetchUrlList nodeEnv organizationKey =
    Http.send UrlLoaded (requestUrls nodeEnv organizationKey)
