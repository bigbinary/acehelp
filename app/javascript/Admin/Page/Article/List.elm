module Page.Article.List exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Admin.Request.Article exposing (..)
import Admin.Data.Article exposing (..)
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
    = ArticleListLoaded (Result GQLClient.Error (List ArticleSummary))
    | OnArticleEditClick ArticleId
    | OnArticleCreateClick
    | UpdateArticleStatus ArticleId ArticleStatus
    | UpdateArticleStatusResponse (Result GQLClient.Error Article)
    | DeleteArticle ArticleId
    | DeleteArticleResponse (Result GQLClient.Error ArticleId)


update : Msg -> Model -> ( Model, List (ReaderCmd Msg) )
update msg model =
    case msg of
        ArticleListLoaded (Ok articlesList) ->
            ( { model
                | articles = articlesList
                , error = Nothing
              }
            , []
            )

        ArticleListLoaded (Err err) ->
            ( { model | error = Just (toString err) }, [] )

        DeleteArticle articleId ->
            ( model, [ Strict <| Reader.map (Task.attempt DeleteArticleResponse) <| requestDeleteArticle articleId ] )

        DeleteArticleResponse (Ok id) ->
            let
                articles =
                    List.filter (\m -> m.id /= id) model.articles
            in
                ( { model | articles = articles }, [] )

        DeleteArticleResponse (Err error) ->
            ( { model | error = Just (toString error) }, [] )

        UpdateArticleStatus articleId articleStatus ->
            ( model, [ Strict <| Reader.map (Task.attempt UpdateArticleStatusResponse) <| requestUpdateArticleStatus articleId articleStatus ] )

        UpdateArticleStatusResponse (Ok newArticle) ->
            let
                articles =
                    List.map
                        (\article ->
                            if article.id == newArticle.id then
                                { article | status = newArticle.status }
                            else
                                article
                        )
                        model.articles
            in
                ( { model | articles = articles }, [] )

        UpdateArticleStatusResponse (Err error) ->
            ( { model | error = Just (toString error) }, [] )

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
            [ onClick (UpdateArticleStatus article.id article.status)
            , class "actionButton btn btn-primary"
            ]
            [ text (statusButtonText article) ]
        , button
            [ article.id |> DeleteArticle |> onClick
            , class "actionButton btn btn-primary"
            ]
            [ text " Delete Article" ]
        ]


statusButtonText : ArticleSummary -> String
statusButtonText article =
    case article.status of
        "offline" ->
            "Mark Online"

        _ ->
            "Mark Offline"
