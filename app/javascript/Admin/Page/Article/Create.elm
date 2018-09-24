module Page.Article.Create exposing (Model, Msg(..), articleInputs, init, initModel, save, update, view)

import Admin.Data.Article exposing (..)
import Admin.Data.Category exposing (..)
import Admin.Data.Common exposing (..)
import Admin.Data.ReaderCmd exposing (..)
import Admin.Data.Url exposing (UrlData, UrlId)
import Admin.Request.Article exposing (..)
import Admin.Request.Category exposing (..)
import Admin.Request.Helper exposing (ApiKey)
import Admin.Request.Url exposing (..)
import Field exposing (..)
import GraphQL.Client.Http as GQLClient
import Helpers exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Page.Article.Common exposing (..)
import Reader exposing (Reader)
import Route exposing (..)
import Task exposing (Task)



-- Model


type alias Model =
    { title : Field String String
    , desc : Field String String
    , articleId : Maybe ArticleId
    , categories : List (Option Category)
    , urls : List (Option UrlData)
    , status : SaveSatus
    , errors : List String
    }


initModel : Model
initModel =
    { title = Field (validateEmpty "Title") ""
    , desc = Field (validateEmpty "Article Content") ""
    , articleId = Nothing
    , categories = []
    , urls = []
    , status = None
    , errors = []
    }


init : ( Model, List (ReaderCmd Msg) )
init =
    ( initModel
    , [ Strict <| Reader.map (Task.attempt CategoriesLoaded) requestCategories
      , Strict <| Reader.map (Task.attempt UrlsLoaded) requestUrls
      ]
    )



-- Update


type Msg
    = TitleInput String
    | DescInput String
    | SaveArticle
    | SaveArticleResponse (Result GQLClient.Error ArticleResponse)
    | CategoriesLoaded (Result GQLClient.Error (Maybe (List Category)))
    | CategorySelected (List CategoryId)
    | UrlsLoaded (Result GQLClient.Error (Maybe (List UrlData)))
    | UrlSelected (List UrlId)


update : Msg -> Model -> ( Model, List (ReaderCmd Msg) )
update msg model =
    case msg of
        TitleInput title ->
            ( { model | title = Field.update model.title title }, [] )

        DescInput desc ->
            ( { model | desc = Field.update model.desc desc }, [] )

        SaveArticle ->
            save model

        SaveArticleResponse (Ok id) ->
            ( { model
                | title = Field.update model.title ""
                , desc = Field.update model.desc ""
              }
            , []
            )

        SaveArticleResponse (Err error) ->
            ( { model | errors = [ "There was an error while saving the Article" ] }, [] )

        CategoriesLoaded (Ok receivedCategories) ->
            case receivedCategories of
                Just categories ->
                    ( { model | categories = List.map Unselected categories, status = None }, [] )

                Nothing ->
                    ( model, [] )

        CategoriesLoaded (Err err) ->
            ( { model | errors = [ "There was an error while loading Categories" ] }, [] )

        CategorySelected categoryIds ->
            ( { model | categories = itemSelection categoryIds model.categories }, [] )

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

        UrlSelected selectedUrlIds ->
            ( { model
                | urls =
                    itemSelection selectedUrlIds model.urls
              }
            , []
            )



-- View


view : ApiKey -> Model -> Html Msg
view orgKey model =
    div []
        [ errorView model.errors
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
                        , onInput DescInput
                        ]
                        []
                    ]
                ]
            , div [ class "col-sm article-meta-data-block" ]
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
                    (requestCreateArticle (articleInputs model))
    in
    if Field.isAllValid fields then
        ( { model | errors = [], status = Saving }, [ cmd ] )

    else
        ( { model | errors = errorsIn fields }, [] )


articleInputs : Model -> CreateArticleInputs
articleInputs { title, desc, categories } =
    { title = Field.value title
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
    }
