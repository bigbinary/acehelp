module Page.Article.Edit exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Admin.Data.Article exposing (..)
import Admin.Request.Article exposing (..)
import Admin.Request.Category exposing (..)
import Admin.Request.Url exposing (..)
import Admin.Data.Category exposing (..)
import Admin.Data.Url exposing (UrlData, UrlId)
import Admin.Data.Common exposing (..)
import Admin.Data.Status exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)
import Time
import Field exposing (..)
import Helpers exposing (..)
import Admin.Ports exposing (..)
import Page.Article.Common exposing (..)
import GraphQL.Client.Http as GQLClient
import Admin.Ports exposing (..)
import Admin.Data.ReaderCmd exposing (..)


-- Model


type alias Model =
    { title : Field String String
    , desc : Field String String
    , articleId : ArticleId
    , categories : List (Option Category)
    , urls : List (Option UrlData)
    , error : Maybe String
    , updateTaskId : Maybe Int
    , status : SaveSatus
    , articleStatus : AvailabilitySatus
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
    , error = Nothing
    , updateTaskId = Nothing
    , status = None
    , articleStatus = Offline
    , originalArticle = Nothing
    , isEditable = False
    }


init : ArticleId -> ( Model, List (ReaderCmd Msg) )
init articleId =
    ( initModel articleId
    , [ Strict <| Reader.map (Task.attempt ArticleLoaded) (requestArticleById articleId)
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
    | ArticleLoaded (Result GQLClient.Error (Maybe Article))
    | CategoriesLoaded (Result GQLClient.Error (List Category))
    | CategorySelected (List CategoryId)
    | UrlsLoaded (Result GQLClient.Error (Maybe (List UrlData)))
    | UpdateStatus ArticleId AvailabilitySatus
    | UpdateStatusResponse (Result GQLClient.Error Article)
    | UrlSelected (List UrlId)
    | TrixInitialize ()
    | ReceivedTimeoutId Int
    | TimedOut Int
    | Killed ()
    | EditArticle
    | ResetArticle



-- TODO: Fetch categories to populate categories dropdown


delayTime : Float
delayTime =
    Time.second * 2


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
                ( { model | title = newTitle, error = errors }, [] )

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
                ( { model | desc = newDesc, error = errors }
                , []
                )

        SaveArticle ->
            save model

        SaveArticleResponse (Ok article) ->
            -- NOTE: Redirection handled in Main
            ( model, [] )

        SaveArticleResponse (Err error) ->
            ( { model | error = Just (toString error), status = None }, [] )

        ArticleLoaded (Ok articleResp) ->
            case articleResp of
                Just article ->
                    ( { model
                        | articleId = article.id
                        , title = Field.update model.title article.title
                        , desc = Field.update model.desc article.desc
                        , articleStatus = availablityStatusIso.reverseGet article.status
                        , categories = itemSelection (List.map .id article.categories) model.categories
                        , urls = itemSelection (List.map .id article.urls) model.urls
                        , originalArticle = Just article
                      }
                    , [ Strict <| Reader.Reader <| always <| insertArticleContent article.desc ]
                    )

                Nothing ->
                    ( { model | error = Just "There was an error loading up the article", originalArticle = Nothing }
                    , []
                    )

        ArticleLoaded (Err err) ->
            ( { model | error = Just "There was an error loading up the article", originalArticle = Nothing }
            , []
            )

        CategoriesLoaded (Ok categories) ->
            ( { model
                | categories =
                    case model.originalArticle of
                        Just article ->
                            itemSelection (List.map .id article.categories) model.categories

                        Nothing ->
                            List.map Unselected categories
              }
            , []
            )

        CategoriesLoaded (Err err) ->
            ( { model | error = Just (toString err) }, [] )

        CategorySelected categoryIds ->
            ( { model
                | categories = itemSelection categoryIds model.categories
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
                                    itemSelection (List.map .id article.urls) model.urls

                                Nothing ->
                                    List.map Unselected urls
                      }
                    , []
                    )

                Nothing ->
                    ( { model | error = Just "There was an error loading up Urls" }, [] )

        UrlsLoaded (Err err) ->
            ( { model | error = Just (toString err) }, [] )

        UrlSelected selectedUrlIds ->
            ( { model
                | urls = itemSelection selectedUrlIds model.urls
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
                        , categories = itemSelection (List.map .id article.categories) model.categories
                        , urls = itemSelection (List.map .id article.urls) model.urls
                        , originalArticle = Just article
                        , isEditable = False
                      }
                    , [ Strict <| Reader.Reader <| always <| insertArticleContent article.desc ]
                    )

                Nothing ->
                    ( { model | isEditable = False }, [] )

        UpdateStatus articleId articleStatus ->
            ( { model
                | status = Saving
              }
            , [ Strict <| Reader.map (Task.attempt UpdateStatusResponse) <| requestUpdateArticleStatus articleId articleStatus ]
            )

        UpdateStatusResponse (Ok newArticle) ->
            ( { model
                | originalArticle = Just newArticle
                , articleStatus = availablityStatusIso.reverseGet newArticle.status
                , status = None
              }
            , []
            )

        UpdateStatusResponse (Err error) ->
            ( { model
                | error = Just (toString error)
                , status = None
              }
            , []
            )



-- View


view : Model -> Html Msg
view model =
    div []
        [ errorView model.error
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
                    , h1 [ classList [ ( "hidden", model.isEditable ) ] ] [ text <| Field.value model.title ]
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
                    , div [ id "trix-show", classList [ ( "trix-content", True ), ( "hidden", model.isEditable ) ] ] []
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
                            [ text ("SaveSatus: ") ]
                        , span
                            [ class (statusClass model.articleStatus) ]
                            [ text (availablityStatusIso.get model.articleStatus) ]
                        ]
                    , button
                        [ onClick (UpdateStatus model.articleId model.articleStatus)
                        , class "btn btn-primary"
                        ]
                        [ text ("Mark " ++ (statusToButtonText model.articleStatus)) ]
                    ]
                ]
            ]
        , if model.status == Saving then
            savingIndicator
          else
            text ""
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
    , categoryId =
        List.filterMap
            (\option ->
                case option of
                    Selected category ->
                        Just category.id

                    _ ->
                        Nothing
            )
            categories
            |> List.head
    , urlId =
        List.filterMap
            (\option ->
                case option of
                    Selected url ->
                        Just url.id

                    _ ->
                        Nothing
            )
            urls
            |> List.head
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
            ( { model | error = Nothing, status = Saving }, [ cmd ] )
        else
            ( { model | error = errorsIn fields }, [] )



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ trixInitialize <| TrixInitialize
        , trixChange <| DescInput
        , timeoutInitialized <| ReceivedTimeoutId
        , timedOut <| TimedOut
        ]
