module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (id, class, style)
import Html.Events exposing (onClick)
import Http
import Task
import Reader


-- import Section.CategoryList as CategoryListSection
-- import Section.Article as ArticleSection
-- import Section.ArticleList as ArticleListSection
-- import Section.ContactUs as ContactUsSection

import Section.Article.SuggestedList as SuggestedList
import Section.Article.Article as Article
import Section.Library.Library as Library
import Section.Library.Category as Category
import Section.Contact.ContactUs as ContactUs
import Views.Container exposing (topBar)
import Views.Loading exposing (sectionLoadingView)
import Views.Tabs as Tabs
import Section.Search.SearchBar as SearchBar
import Data.Article exposing (ArticleId, ArticleResponse, ArticleSummary)
import Data.Category exposing (..)
import Data.Common exposing (..)
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
    | SuggestedArticlesSection SuggestedList.Model
    | ArticleSection Article.Model
    | LibrarySection Library.Model
    | CategorySection Category.Model
    | ContactUsSection ContactUs.Model



-- | CategoryListSection CategoryListSection.Model
-- | ArticleListSection ArticleListSection.Model


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



-- UPDATE


type Msg
    = Animate Animation.Msg
    | SetAppState AppState
      -- | CategoryListMsg CategoryListSection.Msg
      -- | ArticleListMsg ArticleListSection.Msg
    | SuggestedArticlesMsg SuggestedList.Msg
      -- | ArticleListLoaded (Result GQLClient.Error (List ArticleSummary))
    | ArticleMsg Article.Msg
    | LibraryMsg Library.Msg
    | CategoryMsg Category.Msg
      -- | ArticleLoaded (Result GQLClient.Error Data.Article.Article)
    | UrlChange Navigation.Location
    | GoBack
    | TabMsg Tabs.Msg
    | ContactUsMsg ContactUs.Msg
    | SearchBarMsg SearchBar.Msg
    | ReceivedUserInfo UserInfo
    | OpenArticleWithId ArticleId


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        transitionToSection =
            transitionTo model

        runReaderCmds =
            sectionCmdToCmd model.nodeEnv model.apiKey
    in
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

            SuggestedArticlesMsg sectionMsg ->
                let
                    currentModel =
                        case getSection model.sectionState of
                            SuggestedArticlesSection model ->
                                model

                            _ ->
                                SuggestedList.initModel

                    ( newModel, cmds ) =
                        SuggestedList.update sectionMsg currentModel
                in
                    ( { model | sectionState = Loaded (SuggestedArticlesSection newModel) }
                    , runReaderCmds SuggestedArticlesMsg cmds
                    )

            ArticleMsg sectionMsg ->
                let
                    currentModel =
                        case getSection model.sectionState of
                            ArticleSection model ->
                                model

                            _ ->
                                Article.initModel

                    ( newModel, cmds ) =
                        Article.update sectionMsg currentModel
                in
                    ( { model | sectionState = Loaded (ArticleSection newModel) }
                    , runReaderCmds ArticleMsg cmds
                    )

            LibraryMsg sectionMsg ->
                let
                    currentModel =
                        case getSection model.sectionState of
                            LibrarySection model ->
                                model

                            _ ->
                                Library.initModel

                    ( newModel, cmds ) =
                        Library.update sectionMsg currentModel
                in
                    case sectionMsg of
                        Library.LoadCategory categoryId ->
                            transitionToSection CategorySection CategoryMsg (Category.init <| Library.getCategoryWithId categoryId currentModel)

                        _ ->
                            ( { model | sectionState = Loaded (LibrarySection newModel) }
                            , runReaderCmds LibraryMsg cmds
                            )

            CategoryMsg sectionMsg ->
                let
                    currentModel =
                        case getSection model.sectionState of
                            CategorySection model ->
                                model

                            _ ->
                                Category.initModel

                    ( newModel, cmds ) =
                        Category.update sectionMsg currentModel
                in
                    case sectionMsg of
                        Category.LoadArticle articleId ->
                            transitionToSection ArticleSection ArticleMsg (Article.init articleId)

            ContactUsMsg sectionMsg ->
                let
                    currentModel =
                        case getSection model.sectionState of
                            ContactUsSection model ->
                                model

                            _ ->
                                ContactUs.initModel model.userInfo.name model.userInfo.email

                    ( newModel, cmds ) =
                        ContactUs.update sectionMsg currentModel
                in
                    ( { model | sectionState = Loaded (ContactUsSection newModel) }
                    , runReaderCmds ContactUsMsg cmds
                    )

            -- CategoryListMsg categoryListMsg ->
            --     case categoryListMsg of
            --         CategoryListSection.LoadCategory categoryId ->
            --             let
            --                 currentArticles =
            --                     Maybe.map
            --                         .articles
            --                         currentCategory
            --                 currentCategory =
            --                     Maybe.andThen (CategoryListSection.getCategoryWithId categoryId)
            --                         (getCategoryListModel <|
            --                             getSection model.sectionState
            --                         )
            --                 getCategoryListModel section =
            --                     case section of
            --                         CategoryListSection model ->
            --                             Just model
            --                         _ ->
            --                             Nothing
            --             in
            --                 case currentArticles of
            --                     Just articles ->
            --                         ( { model
            --                             | sectionState =
            --                                 Loaded <|
            --                                     ArticleListSection
            --                                         { id = Just categoryId
            --                                         , articles = articles
            --                                         }
            --                             , history = ModelHistory model
            --                           }
            --                         , Cmd.none
            --                         )
            --                     Nothing ->
            --                         -- TODO: This is an error case and needs to be handled
            --                         ( model, Cmd.none )
            -- ArticleListMsg articleListMsg ->
            --     case articleListMsg of
            --         ArticleListSection.LoadArticle articleId ->
            --             ( { model
            --                 | sectionState =
            --                     transitionFromSection
            --                         model.sectionState
            --                 , history = ModelHistory model
            --               }
            --             , Task.attempt ArticleLoaded
            --                 (Reader.run (ArticleSection.init articleId)
            --                     ( model.nodeEnv, model.apiKey )
            --                 )
            --             )
            --         ArticleListSection.OpenLibrary ->
            --             update (TabMsg (Tabs.TabSelected Tabs.Library)) model
            -- ArticleListLoaded (Ok articleList) ->
            --     ( { model
            --         | sectionState =
            --             Loaded
            --                 (ArticleListSection
            --                     { id = Nothing
            --                     , articles = articleList
            --                     }
            --                 )
            --       }
            --     , Cmd.none
            --     )
            -- ArticleLoaded (Ok article) ->
            --     ( { model
            --         | sectionState =
            --             Loaded <| ArticleSection <| ArticleSection.defaultModel article
            --       }
            --     , Cmd.none
            --     )
            GoBack ->
                ( getPreviousValidState model, Cmd.none )

            UrlChange location ->
                ( { model | context = Context (getUrlPathData location) }, Cmd.none )

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
                      -- , Task.attempt ArticleLoaded <|
                      --     Reader.run (ArticleSection.init articleId)
                      --         ( model.nodeEnv, model.apiKey )
                    , Cmd.none
                    )

            SearchBarMsg searchBarMsg ->
                ( model, Cmd.none )

            -- let
            --     ( searchModel, searchCmd ) =
            --         SearchBar.update searchBarMsg model.searchQuery
            -- in
            --     case searchBarMsg of
            --         SearchBar.OnSearch ->
            --             ( { model | sectionState = transitionFromSection model.sectionState }
            --             , Maybe.withDefault Cmd.none <|
            --                 Maybe.map (Cmd.map SearchBarMsg) <|
            --                     Maybe.map (flip Reader.run ( model.nodeEnv, model.apiKey ))
            --                         searchCmd
            --             )
            --         SearchBar.SearchResultsReceived (Ok articleListResponse) ->
            --             ( { model
            --                 | sectionState =
            --                     Loaded
            --                         (ArticleListSection
            --                             { id = Nothing
            --                             , articles = articleListResponse.articles
            --                             }
            --                         )
            --               }
            --             , Cmd.none
            --             )
            --         SearchBar.SearchResultsReceived (Err error) ->
            --             ( model
            --             , Cmd.none
            --             )
            --         _ ->
            --             ( { model | searchQuery = searchModel }, Cmd.none )
            -- ContactUsMsg contactUsMsg ->
            --     let
            --         currentContactUsModel =
            --             getContactUsModel <|
            --                 getSection model.sectionState
            --         getContactUsModel section =
            --             case section of
            --                 ContactUsSection model ->
            --                     model
            --                 _ ->
            --                     ContactUsSection.init model.userInfo.name model.userInfo.email
            --         ( newContactUsModel, _ ) =
            --             ContactUsSection.update contactUsMsg currentContactUsModel
            --     in
            --         case contactUsMsg of
            --             ContactUsSection.SendMessage ->
            --                 case (ContactUsSection.isModelSubmittable newContactUsModel) of
            --                     True ->
            --                         ( { model
            --                             | sectionState =
            --                                 TransitioningFrom (ContactUsSection newContactUsModel)
            --                           }
            --                         , Cmd.map ContactUsMsg <|
            --                             Task.attempt ContactUsSection.RequestMessageCompleted
            --                                 (Reader.run
            --                                     (requestAddTicketMutation
            --                                         (ContactUsSection.modelToRequestMessage
            --                                             newContactUsModel
            --                                         )
            --                                     )
            --                                     ( model.nodeEnv, model.apiKey )
            --                                 )
            --                         )
            --                     False ->
            --                         ( { model
            --                             | sectionState =
            --                                 Loaded
            --                                     (ContactUsSection
            --                                         newContactUsModel
            --                                     )
            --                           }
            --                         , Cmd.none
            --                         )
            --             ContactUsSection.RequestMessageCompleted postResponse ->
            --                 ( { model
            --                     | sectionState =
            --                         Loaded
            --                             (ContactUsSection
            --                                 newContactUsModel
            --                             )
            --                   }
            --                 , Cmd.none
            --                 )
            --             _ ->
            --                 ( { model
            --                     | sectionState =
            --                         Loaded
            --                             (ContactUsSection
            --                                 newContactUsModel
            --                             )
            --                   }
            --                 , Cmd.none
            --                 )
            ReceivedUserInfo userInfo ->
                ( { model | userInfo = userInfo }, Cmd.none )


getSectionView : Section -> Html Msg
getSectionView section =
    case section of
        Blank ->
            sectionLoadingView

        Loading ->
            sectionLoadingView

        SuggestedArticlesSection sectionModel ->
            Html.map SuggestedArticlesMsg <| SuggestedList.view sectionModel

        ArticleSection sectionModel ->
            Html.map ArticleMsg <| Article.view sectionModel

        LibrarySection sectionModel ->
            Html.map LibraryMsg <| Library.view sectionModel

        CategorySection sectionModel ->
            Html.map CategoryMsg <| Category.view sectionModel

        ContactUsSection sectionModel ->
            Html.map ContactUsMsg <| ContactUs.view sectionModel



-- CategoryListSection model ->
--     Html.map CategoryListMsg <| CategoryListSection.view model
-- ArticleSection model ->
--     Html.map ArticleMsg <| ArticleSection.view model
-- ArticleListSection model ->
--     Html.map ArticleListMsg <| ArticleListSection.view model
-- ContactUsSection model ->
--     Html.map ContactUsMsg <| ContactUsSection.view model


getSection : SectionState -> Section
getSection sectionState =
    case sectionState of
        Loaded section ->
            section

        TransitioningFrom section ->
            Loading


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
            let
                ( _, cmd ) =
                    SuggestedList.init model.context
            in
                ( Animation.interrupt
                    [ Animation.to
                        [ Animation.opacity 1
                        , Animation.right <| Animation.px 0
                        ]
                    ]
                    model.containerAnimation
                , TransitioningFrom (getSection model.sectionState)
                , sectionCmdToCmd model.nodeEnv model.apiKey SuggestedArticlesMsg cmd
                )

        Minimized ->
            ( Animation.interrupt
                [ Animation.to initAnimation ]
                model.containerAnimation
            , Loaded Blank
            , Cmd.none
            )


transitionTo : Model -> (b -> Section) -> (msg -> msg1) -> ( b, List (SectionCmd msg) ) -> ( Model, Cmd msg1 )
transitionTo model sec msg ( sectionModel, sectionCmds ) =
    case sectionCmds of
        [] ->
            ( { model | sectionState = Loaded (sec sectionModel) }
            , Cmd.none
            )

        _ ->
            ( { model | sectionState = TransitioningFrom (getSection model.sectionState) }
            , sectionCmdToCmd model.nodeEnv model.apiKey msg sectionCmds
            )


onTabChange : Tabs.Tabs -> Model -> ( Model, Cmd Msg )
onTabChange tab model =
    let
        transitionToTab =
            transitionTo model
    in
        case tab of
            Tabs.SuggestedArticles ->
                SuggestedList.init model.context
                    |> transitionToTab SuggestedArticlesSection SuggestedArticlesMsg

            Tabs.Library ->
                Library.init
                    |> transitionToTab LibrarySection LibraryMsg

            Tabs.ContactUs ->
                ContactUs.init model.userInfo.name model.userInfo.email
                    |> transitionToTab ContactUsSection ContactUsMsg



-- VIEW


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
