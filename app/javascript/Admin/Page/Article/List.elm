module Page.Article.List exposing (..)

import Http
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Page.Article.Create as ArticleCreate
import Navigation exposing (..)
import Route
import Request.ArticleRequest exposing (..)
import Request.UrlRequest exposing (..)
import Data.CommonData exposing (..)
import Page.Common.View exposing (renderError)
import Data.ArticleData exposing (..)
import Data.UrlData exposing (..)
import Json.Decode as Json
import Request.Helpers exposing (NodeEnv, ApiKey)
import Task exposing (Task)
import Reader exposing (Reader)
import GraphQL.Client.Http as GQLClient


-- Model


type alias Model =
    { articles : List ArticleSummary
    , urlList : UrlsListResponse
    , url : String
    , error : Error
    }


initModel : Model
initModel =
    { articles = []
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
    | ArticleLoaded (Result GQLClient.Error (List ArticleSummary))
    | Navigate Route.Route


update : Msg -> Model -> ApiKey -> NodeEnv -> ( Model, Cmd Msg )
update msg model organizationKey nodeEnv =
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
            if url == "select_url" then
                ( { model | articles = [] }, Cmd.none )
            else
                ( { model | url = url }, fetchArticlesList nodeEnv organizationKey )

        Navigate page ->
            model ! [ Navigation.newUrl (Route.routeToString page) ]



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
            [ Html.a
                [ onClick (Navigate <| Route.ArticleCreate)
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
                model.articles
            )
        ]


rows : ArticleSummary -> Html Msg
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
                        [ value "select_url" ]
                        [ text "Select URL" ]
                  , option
                        [ value "" ]
                        [ text "All" ]
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


fetchArticlesList : NodeEnv -> ApiKey -> Cmd Msg
fetchArticlesList nodeEnv apiKey =
    Task.attempt ArticleLoaded (Reader.run (requestArticles) ( nodeEnv, apiKey ))


fetchUrlList : String -> String -> Cmd Msg
fetchUrlList nodeEnv organizationKey =
    Http.send UrlLoaded (requestUrls nodeEnv organizationKey)
