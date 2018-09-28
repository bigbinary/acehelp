module Page.Article.Create exposing
    ( Model
    , Msg(..)
    , articleInputs
    , init
    , initModel
    , save
    , update
    , view
    )

import Admin.Data.Article exposing (..)
import Admin.Data.Category exposing (..)
import Admin.Data.Common exposing (..)
import Admin.Data.ReaderCmd exposing (..)
import Admin.Data.Url exposing (UrlData, UrlId)
import Admin.Ports exposing (..)
import Admin.Request.Article exposing (..)
import Admin.Request.Category exposing (..)
import Admin.Request.Helper exposing (ApiKey)
import Admin.Request.Url exposing (..)
import Admin.Views.Common exposing (..)
import Field exposing (..)
import GraphQL.Client.Http as GQLClient
import Helpers exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Page.Article.Common exposing (..)
import Page.Errors exposing (..)
import Reader exposing (Reader)
import Route exposing (..)
import Task exposing (Task)



-- Model


type alias Model =
    { articleId : ArticleId
    , title : Field String String
    , desc : Field String String
    , categories : List (Option Category)
    , urls : List (Option UrlData)
    , status : SaveStatus
    , errors : List String
    , success : Maybe String
    }


initModel : Model
initModel =
    { articleId = ""
    , title = Field (validateEmpty "Title") ""
    , desc = Field (validateEmpty "Article Content") ""
    , categories = []
    , urls = []
    , status = None
    , errors = []
    , success = Nothing
    }


init : ( Model, List (ReaderCmd Msg) )
init =
    ( initModel
    , [ Strict <| Reader.map (Task.attempt ArticleLoaded) requestTemporaryArticle
      , Strict <| Reader.map (Task.attempt CategoriesLoaded) requestCategories
      , Strict <| Reader.map (Task.attempt UrlsLoaded) requestUrls
      ]
    )



-- Update


type Msg
    = TitleInput String
    | DescInput String
    | SaveArticle
    | SaveArticleResponse (Result GQLClient.Error (Maybe Article))
    | CategoriesLoaded (Result GQLClient.Error (Maybe (List Category)))
    | CategorySelected (Option CategoryId)
    | UrlsLoaded (Result GQLClient.Error (Maybe (List UrlData)))
    | ArticleLoaded (Result GQLClient.Error (Maybe TemporaryArticle))
    | UrlSelected (Option UrlId)


update : Msg -> Model -> ( Model, List (ReaderCmd Msg) )
update msg model =
    case msg of
        TitleInput title ->
            ( { model | title = Field.update model.title title }, [] )

        DescInput desc ->
            ( { model | desc = Field.update model.desc desc }, [] )

        SaveArticle ->
            save model

        SaveArticleResponse (Ok articleResp) ->
            case articleResp of
                Just article ->
                    ( { model
                        | articleId = article.id
                        , title = Field.update model.title article.title
                        , desc = Field.update model.desc article.desc
                        , categories = selectItemsInList (List.map (.id >> Selected) article.categories) model.categories
                        , urls = selectItemsInList (List.map (.id >> Selected) article.urls) model.urls
                        , status = None
                        , success = Just "Article updated successfully."
                      }
                    , [ Strict <| Reader.Reader <| always <| insertArticleContent article.desc ]
                    )

                Nothing ->
                    ( { model
                        | errors = [ "There was an error while saving the article" ]
                      }
                    , []
                    )

        SaveArticleResponse (Err error) ->
            ( { model
                | errors = [ "There was an error while saving the article" ]
                , status = None
              }
            , []
            )

        CategoriesLoaded (Ok receivedCategories) ->
            case receivedCategories of
                Just categories ->
                    ( { model | categories = List.map Unselected categories, status = None }, [] )

                Nothing ->
                    ( model, [] )

        CategoriesLoaded (Err err) ->
            ( { model | errors = [ "There was an error while loading Categories" ] }, [] )

        CategorySelected categoryId ->
            ( { model | categories = selectItemInList categoryId model.categories }, [] )

        UrlsLoaded (Ok loadedUrls) ->
            case loadedUrls of
                Just urls ->
                    ( { model
                        | urls =
                            List.map Unselected urls
                      }
                    , []
                    )

                Nothing ->
                    ( { model | errors = [ "There was an error while loading Urls" ] }, [] )

        UrlsLoaded (Err err) ->
            ( { model | errors = [] }, [] )

        ArticleLoaded (Ok articleResp) ->
            case articleResp of
                Just article ->
                    ( { model
                        | articleId = article.id
                        , errors = []
                      }
                    , []
                    )

                Nothing ->
                    ( { model
                        | errors = [ "There was an error loading the article" ]
                      }
                    , []
                    )

        ArticleLoaded (Err err) ->
            ( { model | errors = [] }, [] )

        UrlSelected selectedUrlId ->
            ( { model
                | urls =
                    selectItemInList selectedUrlId model.urls
              }
            , []
            )



-- View


view : ApiKey -> Model -> Html Msg
view orgKey model =
    div []
        [ errorAlertView model.errors
        , successView model.success
        , div [ class "row article-block" ]
            [ div [ class "col-md-8 article-title-content-block" ]
                [ div
                    [ class "row article-title" ]
                    [ input
                        [ Html.Attributes.value <| Field.value model.title
                        , type_ "text"
                        , class "form-control"
                        , placeholder "Title"
                        , onInput TitleInput
                        ]
                        []
                    ]
                , div
                    [ class "row article-content" ]
                    [ node "trix-editor"
                        [ placeholder "Article content goes here.."
                        , onTrixChange DescInput
                        ]
                        []
                    ]
                ]
            , div [ class "col-md-4 article-meta-data-block" ]
                [ multiSelectCategoryList "Categories:" model.categories CategorySelected
                , multiSelectUrlList "Urls:" model.urls UrlSelected
                , button [ id "create-article", type_ "button", class "btn btn-success", onClick SaveArticle ] [ text "Create Article" ]
                , a
                    [ href <| routeToString <| ArticleList orgKey
                    , id "cancel-create-article"
                    , class "btn btn-primary"
                    ]
                    [ text "Cancel" ]
                ]
            ]
        , if model.status == Saving then
            savingIndicator

          else
            text ""
        ]


save : Model -> ( Model, List (ReaderCmd Msg) )
save model =
    let
        fields =
            [ model.title, model.desc ]

        cmd =
            Strict <|
                Reader.map (Task.attempt SaveArticleResponse)
                    (requestUpdateArticle (articleInputs model))
    in
    if Field.isAllValid fields then
        ( { model | errors = [], status = Saving }, [ cmd ] )

    else
        ( { model | errors = errorsIn fields }, [] )


articleInputs : Model -> UpdateArticleInputs
articleInputs { articleId, title, desc, categories, urls } =
    { id = articleId
    , title = Field.value title
    , desc = Field.value desc
    , categoryIds =
        Just <|
            List.filterMap
                (\option ->
                    case option of
                        Selected category ->
                            Just category.id

                        _ ->
                            Nothing
                )
                categories
    , urlIds =
        Just <|
            List.filterMap
                (\option ->
                    case option of
                        Selected url ->
                            Just url.id

                        _ ->
                            Nothing
                )
                urls
    }
