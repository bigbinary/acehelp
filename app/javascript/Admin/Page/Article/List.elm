module Page.Article.List exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Navigation exposing (..)
import Route
import Admin.Request.Article exposing (..)
import Page.Common.View exposing (renderError)
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


update : Msg -> Model -> ApiKey -> NodeEnv -> ( Model, Cmd Msg )
update msg model organizationKey nodeEnv =
    case msg of
        ArticleListLoaded (Ok articlesList) ->
            ( { model | articles = articlesList }, Cmd.none )

        ArticleListLoaded (Err err) ->
            ( { model | error = Just (toString err) }, Cmd.none )

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
        , div
            []
            (List.map
                (\article ->
                    rows article
                )
                model.articles
            )
        , div
            [ class "buttonDiv" ]
            [ Html.a
                [ onClick (Navigate <| Route.ArticleCreate model.organizationKey)
                , class "button primary"
                ]
                [ text "New Article" ]
            ]
        ]


rows : ArticleSummary -> Html Msg
rows article =
    div
        [ onClick <| Navigate <| Route.ArticleEdit article.id ]
        [ text article.title
        ]
