module Page.Url.ArticleList exposing (Model, Msg(..), init, initModel, rows, update, view)

import Admin.Data.Article exposing (..)
import Admin.Data.Common exposing (..)
import Admin.Data.ReaderCmd exposing (..)
import Admin.Data.Status exposing (..)
import Admin.Request.Article exposing (..)
import Admin.Request.Helper exposing (ApiKey)
import Admin.Views.Common exposing (..)
import Dialog
import GraphQL.Client.Http as GQLClient
import Helpers exposing (flip)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Page.Article.Common exposing (statusToButtonText)
import Reader exposing (Reader)
import Route exposing (..)
import Task exposing (Task)



-- Model


type alias Model =
    { articles : List ArticleSummary
    , error : Maybe String
    , showDeleteArticleConfirmation : Acknowledgement ArticleId
    }


initModel : Model
initModel =
    { articles = []
    , error = Nothing
    , showDeleteArticleConfirmation = No
    }


init : ( Model, List (ReaderCmd Msg) )
init =
    ( initModel, [ Strict <| Reader.map (Task.attempt ArticleListLoaded) <| requestAllArticles ] )



-- Update


type Msg
    = ArticleListLoaded (Result GQLClient.Error (Maybe (List ArticleSummary)))


update : Msg -> Model -> ( Model, List (ReaderCmd Msg) )
update msg model =
    case msg of
        ArticleListLoaded (Ok articleList) ->
            case articleList of
                Just articles ->
                    ( { model
                        | articles = articles
                        , error = Nothing
                      }
                    , []
                    )

                Nothing ->
                    ( { model
                        | articles = []
                        , error = Just "There was an error loading articles"
                      }
                    , []
                    )

        ArticleListLoaded (Err err) ->
            ( { model | error = Just "There was an error loading articles" }, [] )



-- View


view : ApiKey -> Model -> Html Msg
view orgKey model =
    div
        [ id "article_list"
        ]
        [ div
            []
            [ Maybe.withDefault (text "") <|
                Maybe.map
                    (\err ->
                        div
                            [ class "alert alert-danger alert-dismissible fade show"
                            , attribute "role" "alert"
                            ]
                            [ text <| "Error: " ++ err
                            ]
                    )
                    model.error
            ]
        , h4 [] [ text "Select an Article" ]
        , div
            [ class "listingSection" ]
            (List.map
                (\article ->
                    rows orgKey model article
                )
                model.articles
            )
        ]


rows : ApiKey -> Model -> ArticleSummary -> Html Msg
rows orgKey model article =
    div
        [ class "listingRow" ]
        [ a
            [ class "textColumn", href <| routeToString <| ArticleUrlMapping orgKey article.id ]
            [ text article.title ]
        ]
