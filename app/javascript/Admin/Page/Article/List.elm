module Page.Article.List exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Navigation exposing (..)
import Route
import Admin.Request.Article exposing (..)
import Admin.Data.Article exposing (..)
import Request.Helpers exposing (NodeEnv, ApiKey)
import Task exposing (Task)
import Reader exposing (Reader)
import GraphQL.Client.Http as GQLClient


-- Model


type alias Model =
    { articles : List ArticleSummary
    , organizationKey : String
    , error : Maybe String
    }


initModel : ApiKey -> Model
initModel organizationKey =
    { articles = []
    , organizationKey = organizationKey
    , error = Nothing
    }


init : ApiKey -> ( Model, Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error (List ArticleSummary)) )
init organizationKey =
    ( initModel organizationKey, requestAllArticles )



-- Update


type Msg
    = ArticleListLoaded (Result GQLClient.Error (List ArticleSummary))
    | Navigate Route.Route
    | DeleteArticle ArticleId
    | DeleteArticleResponse (Result GQLClient.Error ArticleId)


update : Msg -> Model -> ApiKey -> NodeEnv -> ( Model, Cmd Msg )
update msg model organizationKey nodeEnv =
    case msg of
        ArticleListLoaded (Ok articlesList) ->
            ( { model | articles = articlesList }, Cmd.none )

        ArticleListLoaded (Err err) ->
            ( { model | error = Just (toString err) }, Cmd.none )

        Navigate page ->
            ( model, Navigation.newUrl (Route.routeToString page) )

        DeleteArticle articleId ->
            deleteRecord model nodeEnv organizationKey ({ id = articleId })

        DeleteArticleResponse (Ok id) ->
            let
                articles =
                    List.filter (\m -> m.id /= id) model.articles
            in
                ( { model | articles = articles }, Cmd.none )

        DeleteArticleResponse (Err error) ->
            ( { model | error = Just (toString error) }, Cmd.none )



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
        , div
            [ class "listingSection" ]
            (List.map
                (\article ->
                    rows model article
                )
                model.articles
            )
        , button
            [ onClick (Navigate <| Route.ArticleCreate model.organizationKey)
            , class "btn btn-primary"
            ]
            [ text "New Article" ]
        ]


rows : Model -> ArticleSummary -> Html Msg
rows model article =
    div
        [ class "listingRow" ]
        [ span
            [ class "textColumn" ]
            [ text article.title ]
        , button
            [ Route.ArticleEdit model.organizationKey article.id
                |> Navigate
                |> onClick
            , class "actionButton btn btn-primary"
            ]
            [ text "Edit Article" ]
        , button
            [ article.id |> DeleteArticle |> onClick
            , class "actionButton btn btn-primary"
            ]
            [ text " Delete Article" ]
        ]


deleteRecord : Model -> NodeEnv -> ApiKey -> ArticleIdInput -> ( Model, Cmd Msg )
deleteRecord model nodeEnv apiKey articleId =
    let
        cmd =
            Task.attempt DeleteArticleResponse (Reader.run (requestDeleteArticle) ( nodeEnv, apiKey, articleId ))
    in
        ( model, cmd )
