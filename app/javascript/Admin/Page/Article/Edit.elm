module Page.Article.Edit exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Admin.Data.Article exposing (..)
import Admin.Request.Article exposing (..)
import Admin.Request.Category exposing (..)
import Admin.Request.Url exposing (..)
import Request.Helpers exposing (NodeEnv, ApiKey)
import Admin.Data.Category exposing (..)
import Admin.Data.Url exposing (UrlData, UrlId)
import Admin.Data.Common exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)
import Time
import Field exposing (..)
import Field.ValidationResult exposing (..)
import Helpers exposing (..)
import Admin.Ports exposing (..)
import Page.Article.Common exposing (..)
import GraphQL.Client.Http as GQLClient
import Admin.Ports exposing (..)


-- Model


type alias Model =
    { title : Field String String
    , desc : Field String String
    , articleId : ArticleId
    , categories : List (Option Category)
    , urls : List (Option UrlData)
    , error : Maybe String
    , keyboardInputTaskId : Maybe Int
    , status : Status
    , articleDescInserted : Bool
    , originalArticle : Maybe Article
    }


initModel : ArticleId -> Model
initModel articleId =
    { title = Field (validateEmpty "Title") ""
    , desc = Field (validateEmpty "Article Content") ""
    , articleId = articleId
    , categories = []
    , urls = []
    , error = Nothing
    , keyboardInputTaskId = Nothing
    , status = None
    , articleDescInserted = False
    , originalArticle = Nothing
    }


init :
    ArticleId
    -> ( Model, Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error Article), Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error (List Category)), Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error (List UrlData)) )
init articleId =
    ( initModel articleId
    , requestArticleById articleId
    , requestCategories
    , requestUrls
    )



-- Update


type Msg
    = TitleInput String
    | DescInput String
    | SaveArticle
    | SaveArticleResponse (Result GQLClient.Error Article)
    | ArticleLoaded (Result GQLClient.Error Article)
    | CategoriesLoaded (Result GQLClient.Error (List Category))
    | CategorySelected (List CategoryId)
    | UrlsLoaded (Result GQLClient.Error (List UrlData))
    | UrlSelected (List UrlId)
    | TrixInitialize ()
    | ReceivedTimeoutId Int
    | TimedOut Int
    | Killed ()



-- TODO: Fetch categories to populate categories dropdown


delayTime : Float
delayTime =
    Time.second * 3


update : Msg -> Model -> NodeEnv -> ApiKey -> ( Model, Cmd Msg )
update msg model nodeEnv organizationKey =
    case msg of
        TitleInput title ->
            let
                newTitle =
                    Field.update model.title title

                errors =
                    errorsIn [ newTitle, model.desc ]
            in
                ( { model | title = newTitle, error = errors }, setTimeout delayTime )

        ReceivedTimeoutId id ->
            let
                killCmd =
                    case model.keyboardInputTaskId of
                        Just oldId ->
                            clearTimeout oldId

                        Nothing ->
                            Cmd.none
            in
                ( { model | keyboardInputTaskId = Just id }, killCmd )

        TimedOut id ->
            save model nodeEnv organizationKey

        DescInput desc ->
            let
                newDesc =
                    Field.update model.desc desc

                errors =
                    errorsIn [ newDesc, model.title ]
            in
                ( { model | desc = newDesc, error = errors, articleDescInserted = True }
                , if model.articleDescInserted then
                    setTimeout delayTime
                  else
                    Cmd.none
                )

        SaveArticle ->
            save model nodeEnv organizationKey

        SaveArticleResponse (Ok id) ->
            ( { model
                | title = Field.update model.title ""
                , desc = Field.update model.desc ""
                , status = None
              }
            , Cmd.none
            )

        SaveArticleResponse (Err error) ->
            ( { model | error = Just (toString error), status = None }, Cmd.none )

        ArticleLoaded (Ok article) ->
            ( { model
                | articleId = article.id
                , title = Field.update model.title article.title
                , desc = Field.update model.desc article.desc
                , categories = itemSelection (List.map .id article.categories) model.categories
                , originalArticle = Just article
              }
            , insertArticleContent article.desc
            )

        ArticleLoaded (Err err) ->
            ( { model | error = Just "There was an error loading up the article", originalArticle = Nothing }
            , Cmd.none
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
            , Cmd.none
            )

        CategoriesLoaded (Err err) ->
            ( { model | error = Just (toString err) }, Cmd.none )

        CategorySelected categoryIds ->
            ( { model
                | categories = itemSelection categoryIds model.categories
              }
            , setTimeout delayTime
            )

        UrlsLoaded (Ok urls) ->
            ( { model | urls = List.map Unselected urls }, Cmd.none )

        UrlsLoaded (Err err) ->
            ( { model | error = Just (toString err) }, Cmd.none )

        UrlSelected selectedUrlIds ->
            ( { model
                | urls =
                    itemSelection selectedUrlIds model.urls
              }
            , setTimeout delayTime
            )

        TrixInitialize _ ->
            ( model, insertArticleContent <| Field.value model.desc )

        Killed _ ->
            ( model, Cmd.none )



-- View


view : Model -> Html Msg
view model =
    div []
        [ errorView model.error
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
                ]
            ]
        , if model.status == Saving then
            savingIndicator
          else
            text ""
        ]


articleInputs : Model -> UpdateArticleInputs
articleInputs { articleId, title, desc, categories } =
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
    }


save : Model -> NodeEnv -> ApiKey -> ( Model, Cmd Msg )
save model nodeEnv organizationKey =
    let
        fields =
            [ model.title, model.desc ]

        cmd =
            Task.attempt SaveArticleResponse
                (Reader.run
                    (requestUpdateArticle (articleInputs model))
                    ( nodeEnv, organizationKey )
                )
    in
        if Field.isAllValid fields && maybeToBool model.originalArticle then
            ( { model | error = Nothing, status = Saving }, cmd )
        else
            ( { model | error = errorsIn fields }, Cmd.none )



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ trixInitialize <| TrixInitialize
        , trixChange <| DescInput
        , timeoutInitialized <| ReceivedTimeoutId
        , timedOut <| TimedOut
        ]
