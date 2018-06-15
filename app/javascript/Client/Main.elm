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
import Views.Container exposing (topBar)
import Views.Loading exposing (sectionLoadingView)
import Views.Tabs exposing (tabView)
import Data.Article exposing (..)
import Data.Category exposing (..)
import Request.Helpers exposing (NodeEnv, Context(..))
import Utils exposing (getUrlPathData)
import Animation
import Navigation
import FontAwesome.Solid as SolidIcon


-- MODEL


type alias Flags =
    { node_env : String
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


type SectionState
    = Loaded Section
    | TransitioningFrom Section


type alias Model =
    { nodeEnv : NodeEnv
    , sectionState : SectionState
    , containerAnimation : Animation.State
    , currentAppState : AppState
    , context : Context
    , history : ModelHistory
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
      , sectionState = Loaded Blank
      , containerAnimation = Animation.style initAnimation
      , currentAppState = Minimized
      , context = Context <| getUrlPathData location
      , history = NoHistory
      }
    , Cmd.none
    )


minimizedView : Html Msg
minimizedView =
    div [ id "mini-view", style [ ( "background-color", "rgb(60, 170, 249)" ), ( "color", "#fff" ) ], onClick (SetAppState Maximized) ]
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
            , Html.map TabMsg <| tabView [ Views.Tabs.SuggestedArticles, Views.Tabs.Library, Views.Tabs.ContactUs ]
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
    | CategoryListLoaded (Result Http.Error Categories)
    | ArticleListMsg ArticleListSection.Msg
    | ArticleListLoaded (Result Http.Error ArticleListResponse)
    | ArticleMsg
    | ArticleLoaded (Result Http.Error ArticleResponse)
    | UrlChange Navigation.Location
    | GoBack
    | TabMsg Views.Tabs.Msgs



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
            ArticleSection.view model

        ArticleListSection model ->
            Html.map ArticleListMsg <| ArticleListSection.view model


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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Animate animationMsg ->
            ( { model
                | containerAnimation = Animation.update animationMsg model.containerAnimation
              }
            , Cmd.none
            )

        SetAppState appState ->
            let
                ( animation, newSectionState, cmd ) =
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
                              -- TODO: Pass ApiKey Instead of blank string
                            , cmdForSuggestedArticles model
                            )

                        Minimized ->
                            ( Animation.interrupt
                                [ Animation.to initAnimation ]
                                model.containerAnimation
                            , Loaded Blank
                            , Cmd.none
                            )
            in
                ( { model | currentAppState = appState, containerAnimation = animation, sectionState = newSectionState }, cmd )

        TabMsg tabMsg ->
            case tabMsg of
                Views.Tabs.TabSelected tab target ->
                    cmdForTab (Debug.log (Views.Tabs.tabToString tab) tab) model

        CategoryListLoaded (Ok categories) ->
            ( { model | sectionState = Loaded (CategoryListSection categories.categories) }, Cmd.none )

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

                        getCategoryListModel =
                            (\section ->
                                case section of
                                    CategoryListSection model ->
                                        Just model

                                    _ ->
                                        Nothing
                            )
                    in
                        case currentArticles of
                            Just articles ->
                                ( { model
                                    | sectionState = Loaded <| ArticleListSection { id = Just categoryId, articles = articles }
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
                    ( { model | sectionState = transitionFromSection model.sectionState, history = ModelHistory model }
                    , Task.attempt ArticleLoaded (Reader.run ArticleSection.init ( model.nodeEnv, "", model.context, articleId ))
                    )

        ArticleListLoaded (Ok articleList) ->
            ( { model | sectionState = Loaded (ArticleListSection { id = Nothing, articles = articleList.articles }) }, Cmd.none )

        ArticleLoaded (Ok articleResponse) ->
            ( { model | sectionState = Loaded (ArticleSection articleResponse.article) }, Cmd.none )

        GoBack ->
            ( getPreviousValidState model, Cmd.none )

        UrlChange location ->
            ( { model | context = Context (getUrlPathData location) }, Cmd.none )

        ArticleListLoaded (Err error) ->
            ( { model | sectionState = Loaded (ErrorSection error) }, Cmd.none )

        ArticleLoaded (Err error) ->
            ( { model | sectionState = Loaded (ErrorSection error) }, Cmd.none )

        ArticleMsg ->
            ( model, Cmd.none )


cmdForTab : Views.Tabs.Tabs -> Model -> ( Model, Cmd Msg )
cmdForTab tab model =
    case tab of
        Views.Tabs.SuggestedArticles ->
            ( { model | sectionState = transitionFromSection model.sectionState, history = ModelHistory model }
            , cmdForSuggestedArticles model
            )

        Views.Tabs.Library ->
            ( { model | sectionState = transitionFromSection model.sectionState, history = ModelHistory model }
            , cmdForLibrary model
            )

        Views.Tabs.ContactUs ->
            ( model, Cmd.none )


cmdForSuggestedArticles : Model -> Cmd Msg
cmdForSuggestedArticles model =
    Task.attempt ArticleListLoaded (Reader.run ArticleListSection.init ( model.nodeEnv, "", model.context ))


cmdForLibrary : Model -> Cmd Msg
cmdForLibrary model =
    Task.attempt CategoryListLoaded (Reader.run CategoryListSection.init ( model.nodeEnv, "" ))



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Animation.subscription Animate [ model.containerAnimation ]



-- MAIN


main : Program Flags Model Msg
main =
    Navigation.programWithFlags UrlChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
