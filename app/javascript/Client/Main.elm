module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Http
import Task
import Reader
import Page.CategoryList as CategoryListSection
import Page.Article as ArticleSection
import Page.ArticleList as ArticleListSection
import Page.Error as ErrorSection
import Views.Container exposing (topBar, closeButton)
import Views.Loading exposing (sectionLoadingView)
import Data.Article exposing (..)
import Data.Category exposing (..)
import Request.Helpers exposing (NodeEnv, Context(..))
import Utils exposing (getUrlPathData)
import Animation
import Navigation


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
    }



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
      }
    , Cmd.none
    )


minimizedView : Html Msg
minimizedView =
    div
        [ style
            [ ( "position", "fixed" )
            , ( "width", "100px" )
            , ( "height", "100px" )
            , ( "top", "50%" )
            , ( "right", "0px" )
            , ( "transform", "translateY(-50%)" )
            , ( "background-color", "rgb(60, 170, 249)" )
            , ( "border-radius", "50%" )
            , ( "text-align", "center" )
            , ( "color", "#fff" )
            , ( "font-size", "80px" )
            , ( "font-family", "proxima-nova, Arial, sans-serif" )
            ]
        , onClick (SetAppState Maximized)
        ]
        [ text "?" ]


maximizedView : Model -> Html Msg
maximizedView model =
    div
        (List.concat
            [ Animation.render model.containerAnimation
            , [ style
                    [ ( "position", "fixed" )
                    , ( "top", "0" )
                    , ( "background", "#fff" )
                    , ( "height", "100%" )
                    , ( "width", "720px" )
                    , ( "box-shadow", "0 0 50px 0px rgb(153, 153, 153)" )
                    , ( "font-family", "proxima-nova, Arial, sans-serif" )
                    ]
              ]
            ]
        )
        [ topBar <| SetAppState Minimized
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
                            , Task.attempt ArticleListLoaded (Reader.run ArticleListSection.init ( model.nodeEnv, "", model.context ))
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
                                ( { model | sectionState = Loaded <| ArticleListSection { id = Just categoryId, articles = articles } }
                                , Cmd.none
                                )

                            Nothing ->
                                -- TODO: This is an error case and needs to be handled
                                ( model, Cmd.none )

        ArticleListMsg articleListMsg ->
            case articleListMsg of
                ArticleListSection.LoadArticle articleId ->
                    ( { model | sectionState = transitionFromSection model.sectionState }
                    , Task.attempt ArticleLoaded (Reader.run ArticleSection.init ( model.nodeEnv, "", model.context, articleId ))
                    )

        ArticleListLoaded (Ok articleList) ->
            ( { model | sectionState = Loaded (ArticleListSection { id = Nothing, articles = articleList.articles }) }, Cmd.none )

        ArticleLoaded (Ok articleResponse) ->
            ( { model | sectionState = Loaded (ArticleSection articleResponse.article) }, Cmd.none )

        UrlChange location ->
            ( { model | context = Context (getUrlPathData location) }, Cmd.none )

        ArticleListLoaded (Err error) ->
            ( { model | sectionState = Loaded (ErrorSection error) }, Cmd.none )

        ArticleLoaded (Err error) ->
            ( { model | sectionState = Loaded (ErrorSection error) }, Cmd.none )

        ArticleMsg ->
            ( model, Cmd.none )



-- TODO: Get rid of this all condition handler
-- _ ->
--     ( model, Cmd.none )
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
