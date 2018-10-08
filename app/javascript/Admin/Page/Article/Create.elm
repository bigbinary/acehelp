module Page.Article.Create exposing
    ( Model
    , Msg(..)
    , articleInputs
    , init
    , initModel
    , save
    , subscriptions
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
import Browser.Dom as Dom
import Browser.Events as Events
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
    , saveStatus : SaveStatus
    , errors : List String
    , success : Maybe String
    , attachmentsPath : String
    }


initModel : Model
initModel =
    { articleId = ""
    , title = Field (validateEmpty "Title") ""
    , desc = Field (validateEmpty "Article Content") ""
    , categories = []
    , urls = []
    , saveStatus = None
    , errors = []
    , success = Nothing
    , attachmentsPath = ""
    }


init : ( Model, List (ReaderCmd Msg) )
init =
    ( initModel
    , [ Strict <| Reader.map (Task.attempt ArticleLoaded) requestTemporaryArticle
      , Strict <| Reader.map (Task.attempt CategoriesLoaded) requestCategories
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
    | ArticleLoaded (Result GQLClient.Error (Maybe Article))
    | TrixInitialize ()
    | ChangeEditorHeight (Result Dom.Error Dom.Element)
    | ResizeWindow Int Int
    | AddAttachments


update : Msg -> Model -> ( Model, List (ReaderCmd Msg) )
update msg model =
    case msg of
        TitleInput title ->
            ( { model | title = Field.update model.title title }, [] )

        DescInput desc ->
            ( { model | desc = Field.update model.desc desc }, [] )

        SaveArticle ->
            case model.articleId of
                "" ->
                    ( { model
                        | errors = [ "There was an error while saving the article" ]
                      }
                    , []
                    )

                _ ->
                    save model

        SaveArticleResponse (Ok articleResp) ->
            case articleResp of
                Just article ->
                    ( model, [] )

                Nothing ->
                    ( { model
                        | errors = [ "There was an error while saving the article" ]
                      }
                    , []
                    )

        SaveArticleResponse (Err error) ->
            ( { model
                | errors = [ "There was an error while saving the article" ]
                , saveStatus = None
              }
            , []
            )

        CategoriesLoaded (Ok receivedCategories) ->
            case receivedCategories of
                Just categories ->
                    ( { model | categories = List.map Unselected categories, saveStatus = None }, [] )

                Nothing ->
                    ( model, [] )

        CategoriesLoaded (Err err) ->
            ( { model | errors = [ "There was an error while loading Categories" ] }, [] )

        CategorySelected categoryId ->
            ( { model | categories = selectItemInList categoryId model.categories }, [] )

        ArticleLoaded (Ok articleResp) ->
            case articleResp of
                Just article ->
                    ( { model
                        | articleId = article.id
                        , errors = []
                        , attachmentsPath = article.attachmentsPath
                      }
                    , []
                    )

                Nothing ->
                    ( model, [] )

        ArticleLoaded (Err err) ->
            ( { model | errors = [] }, [] )

        TrixInitialize _ ->
            ( model
            , [ Strict <| Reader.Reader <| always <| Task.attempt ChangeEditorHeight <| Dom.getElement editorId ]
            )

        ChangeEditorHeight (Ok info) ->
            ( model
            , [ Strict <| Reader.Reader <| always <| setEditorHeight <| proposedEditorHeightPayload info ]
            )

        ChangeEditorHeight (Err _) ->
            ( model, [] )

        ResizeWindow _ _ ->
            ( model
            , [ Strict <| Reader.Reader <| always <| Task.attempt ChangeEditorHeight <| Dom.getElement editorId ]
            )

        AddAttachments ->
            ( model
            , [ Strict <| Reader.Reader <| always <| addAttachments () ]
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
                    [ div
                        [ attribute "data-attachments-path" model.attachmentsPath
                        , attribute "data-api-key" orgKey
                        ]
                        [ trixEditorToolbarView
                            AddAttachments
                        , node
                            "trix-editor"
                            [ placeholder "Article content goes here.."
                            , id editorId
                            , attribute "toolbar" "trix-custom-toolbar"
                            , onTrixChange DescInput
                            ]
                            []
                        ]
                    ]
                ]
            , div [ class "col-md-4 article-meta-data-block" ]
                [ multiSelectCategoryList "Categories:" model.categories CategorySelected
                , button [ id "create-article", type_ "button", class "btn btn-success", onClick SaveArticle ] [ text "Create Article" ]
                , a
                    [ href <| routeToString <| ArticleList orgKey
                    , id "cancel-create-article"
                    , class "btn btn-primary"
                    ]
                    [ text "Cancel" ]
                ]
            ]
        , if model.saveStatus == Saving then
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
        ( { model | errors = [], saveStatus = Saving }, [ cmd ] )

    else
        ( { model | errors = errorsIn fields }, [] )


articleInputs : Model -> UpdateArticleInputs
articleInputs { articleId, title, desc, categories } =
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
    }



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ trixInitialize <| TrixInitialize
        , Events.onResize <| \width -> \height -> ResizeWindow width height
        ]
