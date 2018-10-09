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
import Page.View as MainView
import PendingActions exposing (PendingActions)
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
    , originalArticle : Maybe Article
    , showPendingActionsConfirmation : Acknowledgement Msg
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
    , originalArticle = Nothing
    , showPendingActionsConfirmation = No
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
    | IgnorePendingActions Msg
    | HidePendingActionsConfirmationDialog


update : Msg -> PendingActions -> Model -> ( Model, PendingActions, List (ReaderCmd Msg) )
update msg pendingActions model =
    case msg of
        TitleInput title ->
            ( { model | title = Field.update model.title title }, pendingActions, [] )

        DescInput desc ->
            let
                newPendingActions =
                    pendingActionsOnDescriptionChange
                        pendingActions
                        model.originalArticle
                        desc
            in
            ( { model | desc = Field.update model.desc desc }, newPendingActions, [] )

        SaveArticle ->
            if preventSaveForPendingActions pendingActions model.originalArticle then
                ( { model | showPendingActionsConfirmation = Yes (IgnorePendingActions SaveArticle) }
                , pendingActions
                , []
                )

            else
                case model.articleId of
                    "" ->
                        ( { model
                            | errors = [ "There was an error while saving the article" ]
                            , showPendingActionsConfirmation = No
                          }
                        , PendingActions.empty
                        , []
                        )

                    _ ->
                        save pendingActions model

        SaveArticleResponse (Ok articleResp) ->
            case articleResp of
                Just article ->
                    ( { model | originalArticle = Just article }, PendingActions.empty, [] )

                Nothing ->
                    ( { model | errors = [ "There was an error while saving the article" ] }
                    , PendingActions.empty
                    , []
                    )

        SaveArticleResponse (Err error) ->
            ( { model
                | errors = [ "There was an error while saving the article" ]
                , saveStatus = None
              }
            , PendingActions.empty
            , []
            )

        CategoriesLoaded (Ok receivedCategories) ->
            case receivedCategories of
                Just categories ->
                    ( { model | categories = List.map Unselected categories, saveStatus = None }
                    , pendingActions
                    , []
                    )

                Nothing ->
                    ( model, pendingActions, [] )

        CategoriesLoaded (Err err) ->
            ( { model | errors = [ "There was an error while loading Categories" ] }, pendingActions, [] )

        CategorySelected categoryId ->
            ( { model | categories = selectItemInList categoryId model.categories }, pendingActions, [] )

        ArticleLoaded (Ok articleResp) ->
            case articleResp of
                Just article ->
                    ( { model
                        | articleId = article.id
                        , errors = []
                        , attachmentsPath = article.attachmentsPath
                        , originalArticle = Just article
                      }
                    , pendingActions
                    , []
                    )

                Nothing ->
                    ( model, pendingActions, [] )

        ArticleLoaded (Err err) ->
            ( { model | errors = [] }, pendingActions, [] )

        TrixInitialize _ ->
            ( model
            , pendingActions
            , [ Strict <| Reader.Reader <| always <| Task.attempt ChangeEditorHeight <| Dom.getElement editorId ]
            )

        ChangeEditorHeight (Ok info) ->
            ( model
            , pendingActions
            , [ Strict <| Reader.Reader <| always <| setEditorHeight <| proposedEditorHeightPayload info ]
            )

        ChangeEditorHeight (Err _) ->
            ( model, pendingActions, [] )

        ResizeWindow _ _ ->
            ( model
            , pendingActions
            , [ Strict <| Reader.Reader <| always <| Task.attempt ChangeEditorHeight <| Dom.getElement editorId ]
            )

        AddAttachments ->
            ( model
            , pendingActions
            , [ Strict <| Reader.Reader <| always <| addAttachments () ]
            )

        IgnorePendingActions nextMsg ->
            let
                nextCmd =
                    Task.succeed ()
                        |> Task.perform (always nextMsg)
                        |> always
                        |> Reader.Reader
                        |> Strict
            in
            ( { model | showPendingActionsConfirmation = No }, PendingActions.empty, [ nextCmd ] )

        HidePendingActionsConfirmationDialog ->
            ( { model | showPendingActionsConfirmation = No }, pendingActions, [] )



-- View


view : ApiKey -> PendingActions -> Model -> Html Msg
view orgKey pendingActions model =
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
        , MainView.pendingActionsConfirmationDialog
            model.showPendingActionsConfirmation
            pendingActions
            HidePendingActionsConfirmationDialog
        ]


save : PendingActions -> Model -> ( Model, PendingActions, List (ReaderCmd Msg) )
save pendingActions model =
    let
        updatedModel =
            { model | showPendingActionsConfirmation = No }

        fields =
            [ updatedModel.title, updatedModel.desc ]

        cmd =
            Strict <|
                Reader.map (Task.attempt SaveArticleResponse)
                    (requestUpdateArticle (articleInputs updatedModel))
    in
    if Field.isAllValid fields then
        ( { updatedModel | errors = [], saveStatus = Saving }, pendingActions, [ cmd ] )

    else
        ( { updatedModel | errors = errorsIn fields }, pendingActions, [] )


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
