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
import Admin.Data.Url exposing (UrlData, UrlId)
import Admin.Ports exposing (..)
import Admin.Request.Article exposing (..)
import Admin.Request.Category exposing (..)
import Admin.Request.Url exposing (..)
import Admin.Views.Common exposing (errorView)
import Field exposing (..)
import GraphQL.Client.Http as GQLClient
import Helpers exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Page.Article.Common exposing (..)
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
    , urls : List (Option UrlData)
    , errors : List String
    , success : Maybe String
    , updateTaskId : Maybe Int
    , status : SaveStatus
    , articleStatus : AvailabilityStatus
    , originalArticle : Maybe Article
    , isEditable : Bool
    }


initModel : ArticleId -> Model
initModel articleId =
    { title = Field (validateEmpty "Title") ""
    , desc = Field (validateEmpty "Article Content") ""
    , articleId = articleId
    , categories = []
    , urls = []
    , errors = []
    , success = Nothing
    , updateTaskId = Nothing
    , status = None
    , articleStatus = Inactive
    , originalArticle = Nothing
    , isEditable = False
    }


initEditModel : ArticleId -> Model
initEditModel articleId =
    initModel articleId |> (\model -> { model | isEditable = True })


initCmds : ArticleId -> List (ReaderCmd Msg)
initCmds articleId =
    [ Strict <| Reader.map (Task.attempt ArticleLoaded) (requestArticleById articleId)
    , Strict <| Reader.map (Task.attempt CategoriesLoaded) requestCategories
    , Strict <| Reader.map (Task.attempt UrlsLoaded) requestUrls
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
    | UrlsLoaded (Result GQLClient.Error (Maybe (List UrlData)))
    | UpdateStatus ArticleId AvailabilityStatus
    | UpdateStatusResponse (Result GQLClient.Error (Maybe Article))
    | UrlSelected (Option UrlId)
    | TrixInitialize ()
    | ReceivedTimeoutId Int
    | TimedOut Int
    | Killed ()
    | EditArticle
    | ResetArticle
    | RemoveNotifications



-- TODO: Fetch categories to populate categories dropdown


delayTime : Int
delayTime =
    2000


update : Msg -> Model -> ( Model, List (ReaderCmd Msg) )
update msg model =
    case msg of
        TitleInput title ->
            let
                newTitle =
                    Field.update model.title title

                errors =
                    errorsIn [ newTitle, model.desc ]
            in
            ( { model | title = newTitle, errors = errors }, [] )

        ReceivedTimeoutId id ->
            let
                killCmd =
                    case model.updateTaskId of
                        Just oldId ->
                            [ Strict <| Reader.Reader <| always <| clearTimeout oldId ]

                        Nothing ->
                            []
            in
            ( { model | updateTaskId = Just id }, killCmd )

        TimedOut id ->
            save model

        DescInput desc ->
            let
                newDesc =
                    Field.update model.desc desc

                errors =
                    errorsIn [ newDesc, model.title ]
            in
            ( { model | desc = newDesc, errors = errors }
            , []
            )

        SaveArticle ->
            save model

        SaveArticleResponse (Ok articleResp) ->
            case articleResp of
                Just article ->
                    ( { model
                        | articleId = article.id
                        , title = Field.update model.title article.title
                        , desc = Field.update model.desc article.desc
                        , articleStatus = availablityStatusIso.reverseGet article.status
                        , categories = selectItemsInList (List.map (.id >> Selected) article.categories) model.categories
                        , urls = selectItemsInList (List.map (.id >> Selected) article.urls) model.urls
                        , originalArticle = Just article
                        , status = None
                        , isEditable = False
                        , success = Just "Article updated successfully."
                      }
                    , [ Strict <| Reader.Reader <| always <| insertArticleContent article.desc, removeNotificationCmd ]
                    )

                Nothing ->
                    ( { model
                        | errors = [ "There was an error while saving the article" ]
                        , originalArticle = Nothing
                      }
                    , [ removeNotificationCmd ]
                    )

        SaveArticleResponse (Err error) ->
            ( { model
                | errors = [ "There was an error while saving the article" ]
                , status = None
              }
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
                        , urls = selectItemsInList (List.map (.id >> Selected) article.urls) model.urls
                        , originalArticle = Just article
                        , errors = []
                      }
                    , [ Strict <| Reader.Reader <| always <| insertArticleContent article.desc ]
                    )

                Nothing ->
                    ( { model
                        | errors = [ "There was an error loading the article" ]
                        , originalArticle = Nothing
                      }
                    , []
                    )

        ArticleLoaded (Err err) ->
            ( { model
                | errors = [ "There was an error while loading the article" ]
                , originalArticle = Nothing
              }
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
                    , []
                    )

                Nothing ->
                    ( { model | errors = [ "There was an error while loading Categories" ] }, [] )

        CategoriesLoaded (Err err) ->
            ( { model | errors = [ "There was an error while loading Categories" ] }, [] )

        CategorySelected categoryId ->
            ( { model
                | categories = selectItemInList categoryId model.categories
              }
            , [ Strict <| Reader.Reader <| always <| setTimeout delayTime ]
            )

        UrlsLoaded (Ok loadedUrls) ->
            case loadedUrls of
                Just urls ->
                    ( { model
                        | urls =
                            case model.originalArticle of
                                Just article ->
                                    selectItemsInList (List.map (.id >> Selected) article.urls) model.urls

                                Nothing ->
                                    List.map Unselected urls
                        , errors = []
                      }
                    , []
                    )

                Nothing ->
                    ( { model | errors = [ "There was an error loading Urls" ] }
                    , [ removeNotificationCmd ]
                    )

        UrlsLoaded (Err err) ->
            ( { model | errors = [ "There was an error loading Urls" ] }
            , [ removeNotificationCmd ]
            )

        UrlSelected selectedUrlId ->
            ( { model
                | urls = selectItemInList selectedUrlId model.urls
              }
            , [ Strict <| Reader.Reader <| always <| setTimeout delayTime ]
            )

        TrixInitialize _ ->
            ( model, [ Strict <| Reader.Reader <| always <| insertArticleContent <| Field.value model.desc ] )

        Killed _ ->
            ( model, [] )

        EditArticle ->
            ( { model | isEditable = True }, [] )

        ResetArticle ->
            case model.originalArticle of
                Just article ->
                    ( { model
                        | articleId = article.id
                        , title = Field.update model.title article.title
                        , desc = Field.update model.desc article.desc
                        , categories =
                            selectItemsInList (List.map (.id >> Selected) article.categories) model.categories
                        , urls = selectItemsInList (List.map (.id >> Selected) article.urls) model.urls
                        , originalArticle = Just article
                        , isEditable = False
                        , errors = []
                      }
                    , [ Strict <| Reader.Reader <| always <| insertArticleContent article.desc ]
                    )

                Nothing ->
                    ( { model | isEditable = False }, [] )

        UpdateStatus articleId articleStatus ->
            ( { model
                | status = Saving
              }
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
                        , status = None
                      }
                    , []
                    )

                Nothing ->
                    ( model, [] )

        UpdateStatusResponse (Err error) ->
            ( { model
                | errors = [ "There was an error updating the article" ]
                , status = None
              }
            , [ removeNotificationCmd ]
            )

        RemoveNotifications ->
            ( { model | errors = [], success = Nothing }, [] )


removeNotificationCmd =
    Unit <|
        Reader.Reader
            (always <|
                Task.perform (always RemoveNotifications) <|
                    Process.sleep 3000
            )



-- View


view : Model -> Html Msg
view model =
    div []
        [ errorView model.errors
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
                    [ div [ classList [ ( "hidden", not model.isEditable ) ] ]
                        [ node "trix-editor"
                            [ classList [ ( "trix-content", True ) ]
                            , id "dubi"
                            , placeholder "Article content goes here.."
                            , onInput DescInput
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
            , div [ class "col-sm article-meta-data-block" ]
                [ multiSelectCategoryList "Categories:" model.categories CategorySelected
                , multiSelectUrlList "Urls:" model.urls UrlSelected
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
    if Field.isAllValid fields && maybeToBool model.originalArticle then
        ( { model | errors = [], status = Saving }, [ cmd ] )

    else
        ( { model | errors = errorsIn fields }, [] )



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ trixInitialize <| TrixInitialize
        , trixChange <| DescInput
        , timeoutInitialized <| ReceivedTimeoutId
        , timedOut <| TimedOut
        ]
