module Page.Article.List exposing (Model, Msg(..), init, initModel, rows, update, view)

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
    | UpdateArticleStatus ArticleId AvailabilityStatus
    | UpdateArticleStatusResponse (Result GQLClient.Error (Maybe Article))
    | OnDeleteArticleClick ArticleId
    | DeleteArticleResponse (Result GQLClient.Error (Maybe ArticleId))
    | AcknowledgeDelete (Acknowledgement ArticleId)


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

        OnDeleteArticleClick articleId ->
            ( { model | showDeleteArticleConfirmation = Yes articleId }, [] )

        AcknowledgeDelete No ->
            ( { model | showDeleteArticleConfirmation = No }, [] )

        AcknowledgeDelete (Yes articleId) ->
            ( { model | showDeleteArticleConfirmation = No }
            , [ Strict <|
                    Reader.map (Task.attempt DeleteArticleResponse) <|
                        requestDeleteArticle articleId
              ]
            )

        DeleteArticleResponse (Ok id) ->
            let
                articles =
                    case id of
                        Just deletedId ->
                            List.filter (\m -> m.id /= deletedId) model.articles

                        Nothing ->
                            model.articles
            in
            ( { model | articles = articles }, [] )

        DeleteArticleResponse (Err error) ->
            ( { model | error = Just "There was an error deleting the article" }, [] )

        UpdateArticleStatus articleId articleStatus ->
            ( model
            , [ Strict <|
                    Reader.map (Task.attempt UpdateArticleStatusResponse) <|
                        requestUpdateArticleStatus articleId articleStatus
              ]
            )

        UpdateArticleStatusResponse (Ok newArticle) ->
            let
                articles =
                    case newArticle of
                        Just updatedArticle ->
                            List.map
                                (\article ->
                                    if article.id == updatedArticle.id then
                                        { article | status = updatedArticle.status }

                                    else
                                        article
                                )
                                model.articles

                        Nothing ->
                            model.articles
            in
            ( { model | articles = articles }, [] )

        UpdateArticleStatusResponse (Err error) ->
            ( { model | error = Just "There was an error while updating the Status" }, [] )



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
        , a
            [ href <| routeToString <| ArticleCreate orgKey
            , class "btn btn-primary"
            ]
            [ text "+ Article" ]
        , div
            [ class "listingSection" ]
            (List.map
                (\article ->
                    rows orgKey model article
                )
                model.articles
            )
        , Dialog.view <|
            case model.showDeleteArticleConfirmation of
                Yes articleId ->
                    Just
                        (dialogConfig
                            { onDecline = AcknowledgeDelete No
                            , title = "Delete Article"
                            , body = "Are you sure you want to delete this Article?"
                            , onAccept = AcknowledgeDelete (Yes articleId)
                            }
                        )

                No ->
                    Nothing
        ]


rows : ApiKey -> Model -> ArticleSummary -> Html Msg
rows orgKey model article =
    div
        [ class "listingRow" ]
        [ a
            [ class "textColumn", href <| routeToString <| ArticleShow orgKey article.id ]
            [ text article.title ]
        , a
            [ href <| routeToString <| ArticleEdit orgKey article.id
            , class "actionButton btn btn-primary"
            ]
            [ text "Edit Article" ]
        , button
            [ onClick (UpdateArticleStatus article.id <| availablityStatusIso.reverseGet article.status)
            , class "actionButton btn btn-primary"
            ]
            [ text ("Mark " ++ (statusToButtonText <| availablityStatusIso.reverseGet article.status)) ]
        , button
            [ article.id |> OnDeleteArticleClick |> onClick
            , class "actionButton btn btn-primary"
            ]
            [ text " Delete Article" ]
        ]
