module Page.Article.Edit exposing
    ( Model
    , Msg(..)
    , articleInputs
    , delayTime
    , editAndSaveView
    , init
    , initCmds
    , initEdit
    , initEditModel
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
import Admin.Data.Status exposing (..)
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
import Process
import Reader exposing (Reader)
import Task exposing (Task)
import Time



-- Model


type alias Model =
    { title : Field String String
    , desc : Field String String
    , articleId : ArticleId
    , categories : List (Option Category)
    , errors : List String
    , success : Maybe String
    , updateTaskId : Maybe Int
    , saveStatus : SaveStatus
    , articleStatus : AvailabilityStatus
    , originalArticle : Maybe Article
    , isEditable : Bool
    , attachmentsPath : String
    , showPendingActionsConfirmation : Acknowledgement Msg
    }


initModel : ArticleId -> Model
initModel articleId =
    { title = Field (validateEmpty "Title") ""
    , desc = Field (validateEmpty "Article Content") ""
    , articleId = articleId
    , categories = []
    , errors = []
    , success = Nothing
    , updateTaskId = Nothing
    , saveStatus = None
    , articleStatus = Inactive
    , originalArticle = Nothing
    , isEditable = False
    , attachmentsPath = ""
    , showPendingActionsConfirmation = No
    }


initEditModel : ArticleId -> Model
initEditModel articleId =
    initModel articleId |> (\model -> { model | isEditable = True })


initCmds : ArticleId -> List (ReaderCmd Msg)
initCmds articleId =
    [ Strict <| Reader.map (Task.attempt ArticleLoaded) (requestArticleById articleId)
    , Strict <| Reader.map (Task.attempt CategoriesLoaded) requestCategories
    ]


init : ArticleId -> ( Model, List (ReaderCmd Msg) )
init articleId =
    ( initModel articleId
    , initCmds articleId
    )


initEdit : ArticleId -> ( Model, List (ReaderCmd Msg) )
initEdit articleId =
    ( initEditModel articleId
    , initCmds articleId
    )



-- Update


type Msg
    = TitleInput String
    | DescInput String
    | SaveArticle
    | SaveArticleResponse (Result GQLClient.Error (Maybe Article))
    | ArticleLoaded (Result GQLClient.Error (Maybe Article))
    | CategoriesLoaded (Result GQLClient.Error (Maybe (List Category)))
    | CategorySelected (Option CategoryId)
    | UpdateStatus ArticleId AvailabilityStatus
    | UpdateStatusResponse (Result GQLClient.Error (Maybe Article))
    | TrixInitialize ()
    | ReceivedTimeoutId Int
    | TimedOut Int
    | Killed ()
    | EditArticle
    | ResetArticle
    | RemoveNotifications
    | ChangeEditorHeight (Result Dom.Error Dom.Element)
    | ResizeWindow Int Int
    | AddAttachments
    | IgnorePendingActions Msg
    | HidePendingActionsConfirmationDialog



-- TODO: Fetch categories to populate categories dropdown


delayTime : Int
delayTime =
    2000


update : Msg -> PendingActions -> Model -> ( Model, PendingActions, List (ReaderCmd Msg) )
update msg pendingActions model =
    case msg of
        TitleInput title ->
            let
                newTitle =
                    Field.update model.title title

                errors =
                    errorsIn [ newTitle, model.desc ]
            in
            ( { model | title = newTitle, errors = errors }, pendingActions, [] )

        ReceivedTimeoutId id ->
            let
                killCmd =
                    case model.updateTaskId of
                        Just oldId ->
                            [ Strict <| Reader.Reader <| always <| clearTimeout oldId ]

                        Nothing ->
                            []
            in
            ( { model | updateTaskId = Just id }, pendingActions, killCmd )

        TimedOut id ->
            save pendingActions model

        DescInput desc ->
            let
                newDesc =
                    Field.update model.desc desc

                errors =
                    errorsIn [ newDesc, model.title ]

                newPendingActions =
                    if model.isEditable then
                        pendingActionsOnDescriptionChange
                            pendingActions
                            model.originalArticle
                            desc

                    else
                        PendingActions.empty
            in
            ( { model | desc = newDesc, errors = errors }
            , newPendingActions
            , []
            )

        SaveArticle ->
            if preventSaveForPendingActions pendingActions model.originalArticle then
                ( { model | showPendingActionsConfirmation = Yes (IgnorePendingActions SaveArticle) }
                , pendingActions
                , []
                )

            else
                save pendingActions model

        SaveArticleResponse (Ok articleResp) ->
            case articleResp of
                Just article ->
                    ( { model
                        | articleId = article.id
                        , title = Field.update model.title article.title
                        , desc = Field.update model.desc article.desc
                        , articleStatus = availablityStatusIso.reverseGet article.status
                        , categories = selectItemsInList (List.map (.id >> Selected) article.categories) model.categories
                        , originalArticle = Just article
                        , saveStatus = None
                        , isEditable = False
                        , success = Just "Article updated successfully."
                      }
                    , PendingActions.empty
                    , [ Strict <| Reader.Reader <| always <| insertArticleContent article.desc, removeNotificationCmd ]
                    )

                Nothing ->
                    ( { model
                        | errors = [ "There was an error while saving the article" ]
                        , originalArticle = Nothing
                      }
                    , PendingActions.empty
                    , [ removeNotificationCmd ]
                    )

        SaveArticleResponse (Err error) ->
            ( { model
                | errors = [ "There was an error while saving the article" ]
                , saveStatus = None
              }
            , PendingActions.empty
            , [ removeNotificationCmd ]
            )

        ArticleLoaded (Ok articleResp) ->
            case articleResp of
                Just article ->
                    ( { model
                        | articleId = article.id
                        , title = Field.update model.title article.title
                        , desc = Field.update model.desc article.desc
                        , articleStatus = availablityStatusIso.reverseGet article.status
                        , categories = selectItemsInList (List.map (.id >> Selected) article.categories) model.categories
                        , originalArticle = Just article
                        , errors = []
                        , attachmentsPath = article.attachmentsPath
                      }
                    , pendingActions
                    , [ Strict <| Reader.Reader <| always <| insertArticleContent article.desc ]
                    )

                Nothing ->
                    ( { model
                        | errors = [ "There was an error loading the article" ]
                        , originalArticle = Nothing
                      }
                    , pendingActions
                    , []
                    )

        ArticleLoaded (Err err) ->
            ( { model
                | errors = [ "There was an error while loading the article" ]
                , originalArticle = Nothing
              }
            , pendingActions
            , []
            )

        CategoriesLoaded (Ok receivedCategories) ->
            case receivedCategories of
                Just categories ->
                    ( { model
                        | categories =
                            case model.originalArticle of
                                Just article ->
                                    selectItemsInList (List.map (.id >> Selected) article.categories) model.categories

                                Nothing ->
                                    List.map Unselected categories
                        , errors = []
                      }
                    , pendingActions
                    , []
                    )

                Nothing ->
                    ( { model | errors = [ "There was an error while loading Categories" ] }, pendingActions, [] )

        CategoriesLoaded (Err err) ->
            ( { model | errors = [ "There was an error while loading Categories" ] }, pendingActions, [] )

        CategorySelected categoryId ->
            ( { model
                | categories = selectItemInList categoryId model.categories
              }
            , pendingActions
            , [ Strict <| Reader.Reader <| always <| setTimeout delayTime ]
            )

        TrixInitialize _ ->
            ( model
            , pendingActions
            , [ Strict <| Reader.Reader <| always <| insertArticleContent <| Field.value model.desc
              , Strict <| Reader.Reader <| always <| Task.attempt ChangeEditorHeight <| Dom.getElement editorId
              ]
            )

        Killed _ ->
            ( model, pendingActions, [] )

        EditArticle ->
            let
                cmd =
                    Process.sleep 100.0
                        |> (\_ -> Dom.getElement editorId)
                        |> Task.attempt ChangeEditorHeight
                        |> always
                        |> Reader.Reader
                        |> Strict
            in
            ( { model | isEditable = True }, pendingActions, [ cmd ] )

        ResetArticle ->
            if PendingActions.isEmpty pendingActions then
                case model.originalArticle of
                    Just article ->
                        ( { model
                            | articleId = article.id
                            , title = Field.update model.title article.title
                            , desc = Field.update model.desc article.desc
                            , categories =
                                selectItemsInList (List.map (.id >> Selected) article.categories) model.categories
                            , originalArticle = Just article
                            , isEditable = False
                            , errors = []
                          }
                        , pendingActions
                        , [ Strict <| Reader.Reader <| always <| insertArticleContent article.desc ]
                        )

                    Nothing ->
                        ( { model | isEditable = False }, pendingActions, [] )

            else
                ( { model | showPendingActionsConfirmation = Yes (IgnorePendingActions ResetArticle) }
                , pendingActions
                , []
                )

        UpdateStatus articleId articleStatus ->
            ( { model | saveStatus = Saving }
            , pendingActions
            , [ Strict <|
                    Reader.map (Task.attempt UpdateStatusResponse) <|
                        requestUpdateArticleStatus articleId articleStatus
              ]
            )

        UpdateStatusResponse (Ok newArticle) ->
            case newArticle of
                Just article ->
                    ( { model
                        | originalArticle = Just article
                        , articleStatus = availablityStatusIso.reverseGet article.status
                        , saveStatus = None
                      }
                    , pendingActions
                    , []
                    )

                Nothing ->
                    ( model, pendingActions, [] )

        UpdateStatusResponse (Err error) ->
            ( { model
                | errors = [ "There was an error updating the article" ]
                , saveStatus = None
              }
            , pendingActions
            , [ removeNotificationCmd ]
            )

        RemoveNotifications ->
            ( { model | errors = [], success = Nothing }, pendingActions, [] )

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
            ( { model | showPendingActionsConfirmation = No }
            , PendingActions.empty
            , [ nextCmd ]
            )

        HidePendingActionsConfirmationDialog ->
            ( { model | showPendingActionsConfirmation = No }, pendingActions, [] )


removeNotificationCmd =
    Unit <|
        Reader.Reader
            (always <|
                Task.perform (always RemoveNotifications) <|
                    Process.sleep 3000
            )



-- View


view : ApiKey -> PendingActions -> Model -> Html Msg
view orgKey pendingActions model =
    div []
        [ errorAlertView model.errors
        , successView model.success
        , div [ class "row article-block" ]
            [ div [ class "col-md-8 article-title-content-block" ]
                [ editAndSaveView model.isEditable
                , div
                    [ class "row article-title" ]
                    [ input
                        [ Html.Attributes.value <| Field.value model.title
                        , type_ "text"
                        , classList [ ( "form-control", True ), ( "hidden", not model.isEditable ) ]
                        , placeholder "Title"
                        , onInput TitleInput
                        ]
                        []
                    , h1 [ classList [ ( "hidden", model.isEditable ) ] ]
                        [ text <|
                            Field.value model.title
                        ]
                    ]
                , div
                    [ class "row article-content" ]
                    [ div
                        [ classList [ ( "hidden", not model.isEditable ) ]
                        , attribute "data-attachments-path" model.attachmentsPath
                        , attribute "data-api-key" orgKey
                        ]
                        [ trixEditorToolbarView AddAttachments
                        , node
                            "trix-editor"
                            [ classList [ ( "trix-content", True ) ]
                            , id editorId
                            , attribute "toolbar" "trix-custom-toolbar"
                            , placeholder "Article content goes here.."
                            , onTrixChange DescInput
                            ]
                            []
                        ]
                    , div
                        [ id "trix-show"
                        , classList
                            [ ( "trix-content", True )
                            , ( "hidden"
                              , model.isEditable
                              )
                            ]
                        ]
                        []
                    ]
                ]
            , div [ class "col-md-4 article-meta-data-block" ]
                [ multiSelectCategoryList "Categories:" model.categories CategorySelected
                , div
                    [ class "article-block article-status-block" ]
                    [ div
                        []
                        [ span
                            []
                            [ text "Status: " ]
                        , span
                            [ class (statusClass model.articleStatus) ]
                            [ text (availablityStatusIso.get model.articleStatus) ]
                        ]
                    , button
                        [ onClick (UpdateStatus model.articleId model.articleStatus)
                        , class "btn btn-primary"
                        ]
                        [ text ("Mark " ++ statusToButtonText model.articleStatus) ]
                    ]
                ]
            ]
        , MainView.pendingActionsConfirmationDialog
            model.showPendingActionsConfirmation
            pendingActions
            HidePendingActionsConfirmationDialog
        ]


editAndSaveView : Bool -> Html Msg
editAndSaveView isisEditable =
    case isisEditable of
        True ->
            div [ class "row article-save-edit" ]
                [ button [ class "btn btn-primary", onClick SaveArticle ] [ text "Save" ]
                , button [ class "btn btn-primary", onClick ResetArticle ] [ text "Cancel" ]
                ]

        False ->
            div [ class "row article-save-edit" ]
                [ button [ class "btn btn-primary", onClick EditArticle ] [ text "Edit" ] ]


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
    if Field.isAllValid fields && maybeToBool updatedModel.originalArticle then
        ( { updatedModel | errors = [], saveStatus = Saving }, pendingActions, [ cmd ] )

    else
        ( { updatedModel | errors = errorsIn fields }, pendingActions, [] )



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ trixInitialize <| TrixInitialize
        , timeoutInitialized <| ReceivedTimeoutId
        , timedOut <| TimedOut
        , Events.onResize <| \width -> \height -> ResizeWindow width height
        ]
