module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (id, class, style)
import Html.Events exposing (onClick)
import Http
import Task
import Reader
import Section.CategoryList as CategoryListSection
import Section.Article as ArticleSection
import Section.ArticleList as ArticleListSection
import Section.Error as ErrorSection
import Section.ContactUs as ContactUsSection
import Views.Container exposing (topBar)
import Views.Loading exposing (sectionLoadingView)
import Views.Tabs as Tabs
import Section.Search as SearchBar
import Data.Article exposing (ArticleId, ArticleResponse, ArticleSummary)
import Data.Category exposing (..)
import Request.ContactUs exposing (..)
import Request.Helpers exposing (ApiKey, NodeEnv, Context(..))
import Utils exposing (getUrlPathData)
import Animation
import Navigation
import FontAwesome.Solid as SolidIcon
import GraphQL.Client.Http as GQLClient
import Ports exposing (..)


-- MODEL


type alias Flags =
    { node_env : String
    , api_key : String
    }


type AppState
    = Minimized
    | Maximized


type Section
    = Blank
    | Loading
    | ErrorSection ErrorSection.Model
    | CategoryListSection CategoryListSection.Model
    | ArticleSection ArticleSection.Model
    | ArticleListSection ArticleListSection.Model
    | ContactUsSection ContactUsSection.Model


type SectionState
    = Loaded Section
    | TransitioningFrom Section


type alias Model =
    { nodeEnv : NodeEnv
    , apiKey : ApiKey
    , sectionState : SectionState
    , containerAnimation : Animation.State
    , currentAppState : AppState
    , context : Context
    , tabModel : Tabs.Model
    , searchQuery : SearchBar.Model
    , history : ModelHistory
    , userInfo : UserInfo
    }


type ModelHistory
    = ModelHistory Model
    | NoHistory



-- INIT


initAnimation : List Animation.Property
initAnimation =
    [ Animation.opacity 0
    , Animation.right <| Animation.px -770
    ]


init : Flags -> Navigation.Location -> ( Model, Cmd Msg )
init flags location =
    ( { nodeEnv = flags.node_env
      , apiKey = flags.api_key
      , sectionState = Loaded Blank
      , containerAnimation = Animation.style initAnimation
      , currentAppState = Minimized
      , context = Context <| getUrlPathData location
      , tabModel = Tabs.modelWithTabs Tabs.allTabs
      , searchQuery = ""
      , history = NoHistory
      , userInfo = { name = "", email = "" }
      }
    , Cmd.none
    )


minimizedView : Html Msg
minimizedView =
    div
        [ id "mini-view"
        , style
            [ ( "background-color", "rgb(60, 170, 249)" )
            , ( "color", "#fff" )
            ]
        , onClick (SetAppState Maximized)
        ]
        [ div [ class "question-icon" ]
            [ SolidIcon.question ]
        ]


maximizedView : Model -> Html Msg
maximizedView model =
    let
        history =
            getModelFromHistory model

        showBackButton =
            case history of
                Just previousModel ->
                    case (getSection previousModel.sectionState) of
                        Blank ->
                            False

                        Loading ->
                            False

                        _ ->
                            True

                Nothing ->
                    False
    in
        div
            (List.concat
                [ Animation.render model.containerAnimation
                , [ id "max-view"
                  ]
                ]
            )
            [ topBar showBackButton GoBack (SetAppState Minimized)
            , Html.map TabMsg <| Tabs.view model.tabModel
            , Html.map SearchBarMsg <| SearchBar.view model.searchQuery "rgb(60, 170, 249)"
            , getSectionView <| getSection model.sectionState
            ]


view : Model -> Html Msg
view model =
    case model.currentAppState of
        Minimized ->
            minimizedView

        Maximized ->
            maximizedView model



-- Msg


type Msg
    = Animate Animation.Msg
    | SetAppState AppState
    | CategoryListMsg CategoryListSection.Msg
    | CategoryListLoaded (Result GQLClient.Error (List Category))
    | ArticleListMsg ArticleListSection.Msg
    | ArticleListLoaded (Result GQLClient.Error (List ArticleSummary))
    | ArticleMsg ArticleSection.Msg
    | ArticleLoaded (Result GQLClient.Error Data.Article.Article)
    | UrlChange Navigation.Location
    | GoBack
    | TabMsg Tabs.Msg
    | ContactUsMsg ContactUsSection.Msg
    | SearchBarMsg SearchBar.Msg
    | ReceivedUserInfo UserInfo
    | OpenArticleWithId ArticleId



-- UPDATE


getSectionView : Section -> Html Msg
getSectionView section =
    case section of
        Blank ->
            sectionLoadingView

        Loading ->
            sectionLoadingView

        ErrorSection model ->
            ErrorSection.view model

        CategoryListSection model ->
            Html.map CategoryListMsg <| CategoryListSection.view model

        ArticleSection model ->
            Html.map ArticleMsg <| ArticleSection.view model

        ArticleListSection model ->
            Html.map ArticleListMsg <| ArticleListSection.view model

        ContactUsSection model ->
            Html.map ContactUsMsg <| ContactUsSection.view model


getSection : SectionState -> Section
getSection sectionState =
    case sectionState of
        Loaded section ->
            section

        TransitioningFrom section ->
            Loading


transitionFromSection : SectionState -> SectionState
transitionFromSection sectionState =
    TransitioningFrom (getSection sectionState)


getModelFromHistory : Model -> Maybe Model
getModelFromHistory modelHistory =
    case modelHistory.history of
        ModelHistory model ->
            Just model

        NoHistory ->
            Nothing


getPreviousValidState : Model -> Model
getPreviousValidState currentModel =
    let
        getValidModelFromSection model =
            case model of
                Just newModel ->
                    case (getSection newModel.sectionState) of
                        Blank ->
                            -- Blank indicates start of app
                            currentModel

                        Loading ->
                            getValidModelFromSection (getModelFromHistory newModel)

                        _ ->
                            newModel

                Nothing ->
                    currentModel

        previousModel =
            getValidModelFromSection <| getModelFromHistory currentModel
    in
        previousModel


setAppState : AppState -> Model -> ( Animation.State, SectionState, Cmd Msg )
setAppState appState model =
    case appState of
        Maximized ->
            ( Animation.interrupt
                [ Animation.to
                    [ Animation.opacity 1
                    , Animation.right <| Animation.px 0
                    ]
                ]
                model.containerAnimation
            , transitionFromSection model.sectionState
            , cmdForSuggestedArticles model
            )

        Minimized ->
            ( Animation.interrupt
                [ Animation.to initAnimation ]
                model.containerAnimation
            , Loaded Blank
            , Cmd.none
            )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Animate animationMsg ->
            ( { model
                | containerAnimation =
                    Animation.update animationMsg
                        model.containerAnimation
              }
            , Cmd.none
            )

        SetAppState appState ->
            let
                ( animation, newSectionState, cmd ) =
                    setAppState appState model
            in
                ( { model
                    | currentAppState = appState
                    , containerAnimation =
                        animation
                    , sectionState = newSectionState
                  }
                , cmd
                )

        TabMsg tabMsg ->
            let
                ( newModel, newCmd ) =
                    case tabMsg of
                        Tabs.TabSelected newTab ->
                            onTabChange newTab model

                ( newTabModel, tabCmd ) =
                    Tabs.update tabMsg model.tabModel
            in
                ( { newModel | tabModel = newTabModel }
                , Cmd.batch
                    [ newCmd
                    , Cmd.map TabMsg tabCmd
                    ]
                )

        CategoryListLoaded (Ok categories) ->
            ( { model | sectionState = Loaded (CategoryListSection categories) }, Cmd.none )

        CategoryListLoaded (Err error) ->
            ( { model | sectionState = Loaded (ErrorSection error) }, Cmd.none )

        CategoryListMsg categoryListMsg ->
            case categoryListMsg of
                CategoryListSection.LoadCategory categoryId ->
                    let
                        currentArticles =
                            Maybe.map
                                .articles
                                currentCategory

                        currentCategory =
                            Maybe.andThen (CategoryListSection.getCategoryWithId categoryId)
                                (getCategoryListModel <|
                                    getSection model.sectionState
                                )

                        getCategoryListModel section =
                            case section of
                                CategoryListSection model ->
                                    Just model

                                _ ->
                                    Nothing
                    in
                        case currentArticles of
                            Just articles ->
                                ( { model
                                    | sectionState =
                                        Loaded <|
                                            ArticleListSection
                                                { id = Just categoryId
                                                , articles = articles
                                                }
                                    , history = ModelHistory model
                                  }
                                , Cmd.none
                                )

                            Nothing ->
                                -- TODO: This is an error case and needs to be handled
                                ( model, Cmd.none )

        ArticleListMsg articleListMsg ->
            case articleListMsg of
                ArticleListSection.LoadArticle articleId ->
                    ( { model
                        | sectionState =
                            transitionFromSection
                                model.sectionState
                        , history = ModelHistory model
                      }
                    , Task.attempt ArticleLoaded
                        (Reader.run (ArticleSection.init articleId)
                            ( model.nodeEnv, model.apiKey )
                        )
                    )

                ArticleListSection.OpenLibrary ->
                    update (TabMsg (Tabs.TabSelected Tabs.Library)) model

        ArticleListLoaded (Ok articleList) ->
            ( { model
                | sectionState =
                    Loaded
                        (ArticleListSection
                            { id = Nothing
                            , articles = articleList
                            }
                        )
              }
            , Cmd.none
            )

        ArticleLoaded (Ok article) ->
            ( { model
                | sectionState =
                    Loaded <| ArticleSection <| ArticleSection.defaultModel article
              }
            , Cmd.none
            )

        GoBack ->
            ( getPreviousValidState model, Cmd.none )

        UrlChange location ->
            ( { model | context = Context (getUrlPathData location) }, Cmd.none )

        ArticleListLoaded (Err error) ->
            let
                ( errModel, errCmd ) =
                    ( { model | sectionState = Loaded (ErrorSection error) }, Cmd.none )
            in
                case error of
                    GQLClient.HttpError (Http.BadStatus response) ->
                        case response.status.code of
                            404 ->
                                ( { model
                                    | sectionState =
                                        Loaded
                                            (ArticleListSection
                                                { id = Nothing
                                                , articles = []
                                                }
                                            )
                                  }
                                , Cmd.none
                                )

                            _ ->
                                ( errModel, errCmd )

                    _ ->
                        ( errModel, errCmd )

        ArticleLoaded (Err error) ->
            ( { model | sectionState = Loaded (ErrorSection error) }, Cmd.none )

        ArticleMsg articleMsg ->
            let
                currentArticleModel =
                    getArticleModel <|
                        getSection model.sectionState

                getArticleModel section =
                    case section of
                        ArticleSection model ->
                            model

                        _ ->
                            ArticleSection.defaultModel { id = "", title = "", content = "" }

                ( newArticleModel, cmd ) =
                    ArticleSection.update articleMsg currentArticleModel
            in
                ( { model | sectionState = Loaded (ArticleSection newArticleModel) }
                , Maybe.withDefault Cmd.none <|
                    Maybe.map (Cmd.map ArticleMsg) <|
                        Maybe.map (flip Reader.run ( model.nodeEnv, model.apiKey )) cmd
                )

        OpenArticleWithId articleId ->
            let
                ( animation, newSectionState, cmd ) =
                    setAppState Maximized model
            in
                ( { model
                    | currentAppState = Maximized
                    , containerAnimation = animation
                    , sectionState = newSectionState
                  }
                , Task.attempt ArticleLoaded <|
                    Reader.run (ArticleSection.init articleId)
                        ( model.nodeEnv, model.apiKey )
                )

        SearchBarMsg searchBarMsg ->
            let
                ( searchModel, searchCmd ) =
                    SearchBar.update searchBarMsg model.searchQuery
            in
                case searchBarMsg of
                    SearchBar.OnSearch ->
                        ( { model | sectionState = transitionFromSection model.sectionState }
                        , Maybe.withDefault Cmd.none <|
                            Maybe.map (Cmd.map SearchBarMsg) <|
                                Maybe.map (flip Reader.run ( model.nodeEnv, model.apiKey ))
                                    searchCmd
                        )

                    SearchBar.SearchResultsReceived (Ok articleListResponse) ->
                        ( { model
                            | sectionState =
                                Loaded
                                    (ArticleListSection
                                        { id = Nothing
                                        , articles = articleListResponse.articles
                                        }
                                    )
                          }
                        , Cmd.none
                        )

                    SearchBar.SearchResultsReceived (Err error) ->
                        ( { model
                            | sectionState =
                                Loaded
                                    (ErrorSection
                                        (GQLClient.HttpError error)
                                    )
                          }
                        , Cmd.none
                        )

                    _ ->
                        ( { model | searchQuery = searchModel }, Cmd.none )

        ContactUsMsg contactUsMsg ->
            let
                currentContactUsModel =
                    getContactUsModel <|
                        getSection model.sectionState

                getContactUsModel section =
                    case section of
                        ContactUsSection model ->
                            model

                        _ ->
                            ContactUsSection.init model.userInfo.name model.userInfo.email

                ( newContactUsModel, _ ) =
                    ContactUsSection.update contactUsMsg currentContactUsModel
            in
                case contactUsMsg of
                    ContactUsSection.SendMessage ->
                        case (ContactUsSection.isModelSubmittable newContactUsModel) of
                            True ->
                                ( { model
                                    | sectionState =
                                        TransitioningFrom (ContactUsSection newContactUsModel)
                                  }
                                , Cmd.map ContactUsMsg <|
                                    Task.attempt ContactUsSection.RequestMessageCompleted
                                        (Reader.run
                                            (requestAddTicketMutation
                                                (ContactUsSection.modelToRequestMessage
                                                    newContactUsModel
                                                )
                                            )
                                            ( model.nodeEnv, model.apiKey )
                                        )
                                )

                            False ->
                                ( { model
                                    | sectionState =
                                        Loaded
                                            (ContactUsSection
                                                newContactUsModel
                                            )
                                  }
                                , Cmd.none
                                )

                    ContactUsSection.RequestMessageCompleted postResponse ->
                        ( { model
                            | sectionState =
                                Loaded
                                    (ContactUsSection
                                        newContactUsModel
                                    )
                          }
                        , Cmd.none
                        )

                    _ ->
                        ( { model
                            | sectionState =
                                Loaded
                                    (ContactUsSection
                                        newContactUsModel
                                    )
                          }
                        , Cmd.none
                        )

        ReceivedUserInfo userInfo ->
            ( { model | userInfo = userInfo }, Cmd.none )


onTabChange : Tabs.Tabs -> Model -> ( Model, Cmd Msg )
onTabChange tab model =
    case tab of
        Tabs.SuggestedArticles ->
            ( { model
                | sectionState = transitionFromSection model.sectionState
                , history = ModelHistory model
              }
            , cmdForSuggestedArticles model
            )

        Tabs.Library ->
            ( { model
                | sectionState = transitionFromSection model.sectionState
                , history = ModelHistory model
              }
            , cmdForLibrary model
            )

        Tabs.ContactUs ->
            ( { model
                | sectionState =
                    Loaded <|
                        ContactUsSection <|
                            ContactUsSection.init model.userInfo.name model.userInfo.email
              }
            , Cmd.none
            )


cmdForSuggestedArticles : Model -> Cmd Msg
cmdForSuggestedArticles model =
    Task.attempt ArticleListLoaded
        (Reader.run (ArticleListSection.init model.context)
            ( model.nodeEnv, model.apiKey )
        )


cmdForLibrary : Model -> Cmd Msg
cmdForLibrary model =
    Task.attempt CategoryListLoaded
        (Reader.run CategoryListSection.init
            ( model.nodeEnv
            , model.apiKey
            )
        )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Animation.subscription Animate [ model.containerAnimation ]
        , userInfo <| decodeUserInfo >> ReceivedUserInfo
        , openArticle <| OpenArticleWithId
        ]



-- MAIN


main : Program Flags Model Msg
main =
    Navigation.programWithFlags UrlChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
