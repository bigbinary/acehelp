module Page.Article.List exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Admin.Request.Article exposing (..)
import Admin.Data.Article exposing (..)
import Admin.Data.Status exposing (..)
import Page.Article.Common exposing (statusToButtonText)
import Task exposing (Task)
import Reader exposing (Reader)
import GraphQL.Client.Http as GQLClient
import Admin.Data.ReaderCmd exposing (..)


-- Model


type alias Model =
    { articles : List ArticleSummary
    , error : Maybe String
    }


initModel : Model
initModel =
    { articles = []
    , error = Nothing
    }


init : ( Model, List (ReaderCmd Msg) )
init =
    ( initModel, [ Strict <| Reader.map (Task.attempt ArticleListLoaded) <| requestAllArticles ] )



-- Update


type Msg
    = ArticleListLoaded (Result GQLClient.Error (Maybe (List ArticleSummary)))
    | OnArticleEditClick ArticleId
    | OnArticleCreateClick
    | UpdateArticleStatus ArticleId AvailabilitySatus
    | UpdateArticleStatusResponse (Result GQLClient.Error (Maybe Article))
    | DeleteArticle ArticleId
    | DeleteArticleResponse (Result GQLClient.Error (Maybe ArticleId))


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

        DeleteArticle articleId ->
            ( model, [ Strict <| Reader.map (Task.attempt DeleteArticleResponse) <| requestDeleteArticle articleId ] )

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
            ( model, [ Strict <| Reader.map (Task.attempt UpdateArticleStatusResponse) <| requestUpdateArticleStatus articleId articleStatus ] )

        UpdateArticleStatusResponse (Ok newArticle) ->
            let
                articles =
                    case newArticle of
                        Just article ->
                            List.map
                                (\article ->
                                    if article.id == article.id then
                                        { article | status = article.status }
                                    else
                                        article
                                )
                                model.articles

                        Nothing ->
                            model.articles
            in
                ( { model | articles = articles }, [] )

        UpdateArticleStatusResponse (Err error) ->
            ( { model | error = Just "There was an error wile updating the Status" }, [] )

        OnArticleCreateClick ->
            -- NOTE: Handled in Main
            ( model, [] )

        OnArticleEditClick articleId ->
            -- NOTE: Handled in Main
            ( model, [] )



-- View


view : Model -> Html Msg
view model =
    div
        [ id "article_list"
        ]
        [ div
            []
            [ Maybe.withDefault (text "") <|
                Maybe.map
                    (\err ->
                        div [ class "alert alert-danger alert-dismissible fade show", attribute "role" "alert" ]
                            [ text <| "Error: " ++ err
                            ]
                    )
                    model.error
            ]
        , button
            [ onClick OnArticleCreateClick
            , class "btn btn-primary"
            ]
            [ text "+ Article" ]
        , div
            [ class "listingSection" ]
            (List.map
                (\article ->
                    rows model article
                )
                model.articles
            )
        ]


rows : Model -> ArticleSummary -> Html Msg
rows model article =
    div
        [ class "listingRow" ]
        [ span
            [ class "textColumn" ]
            [ text article.title ]
        , button
            [ onClick (OnArticleEditClick article.id)
            , class "actionButton btn btn-primary"
            ]
            [ text "Edit Article" ]
        , button
            [ onClick (UpdateArticleStatus article.id <| availablityStatusIso.reverseGet article.status)
            , class "actionButton btn btn-primary"
            ]
            [ text ("Mark " ++ (statusToButtonText <| availablityStatusIso.reverseGet article.status)) ]
        , button
            [ article.id |> DeleteArticle |> onClick
            , class "actionButton btn btn-primary"
            ]
            [ text " Delete Article" ]
        ]
