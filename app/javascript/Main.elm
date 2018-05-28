module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Http
import Task
import Page.CategoryList as CategoryListSection
import Page.Article as ArticleSection
import Page.ArticleList as ArticleListSection
import Views.Container exposing (topBar, closeButton)
import Views.Loading exposing (sectionLoadingView)
import Data.Article exposing (..)
import Data.Category exposing (..)
import Animation


-- MODEL


type AppState
    = Minimized
    | Maximized


type Section
    = Blank
    | CategoryListSection CategoryListSection.Model
    | ArticleSection ArticleSection.Model
    | ArticleListSection ArticleListSection.Model


type SectionState
    = Loaded Section
    | TransitioningFrom Section


type alias Model =
    { sectionState : SectionState
    , containerAnimation : Animation.State
    , currentAppState : AppState
    }



-- INIT


initAnimation : List Animation.Property
initAnimation =
    [ Animation.opacity 0
    , Animation.right <| Animation.px -770
    ]


init : ( Model, Cmd Msg )
init =
    ( { sectionState = Loaded Blank
      , containerAnimation = Animation.style initAnimation
      , currentAppState = Minimized
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
    | ArticleMsg
    | ArticleLoaded (Result Http.Error Article)



-- UPDATE


getSectionView : Section -> Html Msg
getSectionView section =
    case section of
        Blank ->
            sectionLoadingView
        
        Loading ->
            sectionLoadingView

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
                              -- TODO: Call API and retrive contextual support response
                            , Task.attempt CategoryListLoaded CategoryListSection.init
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

        CategoryListMsg aMsg ->
            case aMsg of
                CategoryListSection.LoadCategory categoryId ->
                    let
                        getCategoryListModel =
                            (\section ->
                                case section of
                                    CategoryListSection model ->
                                        Just model

                                    _ ->
                                        Nothing
                            )

                        currentCategory =
                            Maybe.andThen (CategoryListSection.getCategoryWithId categoryId)
                                (getCategoryListModel <|
                                    getSection model.sectionState
                                )

                        currentArticles =
                            Maybe.map
                                .articles
                                currentCategory
                    in
                        case currentArticles of
                            Just articles ->
                                ( { model | sectionState = Loaded <| ArticleListSection { id = categoryId, articles = articles } }
                                , Cmd.none
                                )

                            Nothing ->
                                -- TODO: This is an error case and needs to be handled
                                ( model, Cmd.none )

        ArticleLoaded (Ok article) ->
            ( { model | sectionState = Loaded (ArticleSection article) }, Cmd.none )

        _ ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Animation.subscription Animate [ model.containerAnimation ]



-- MAIN


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
