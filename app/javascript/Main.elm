module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Http
import Task
import Page.ArticleList as ArticleListSection
import Page.Article as ArticleSection
import Views.Container exposing (topBar, closeButton)
import Views.Spinner exposing (spinnerStyle)
import Data.Article exposing (..)
import Animation


-- MODEL


type AppState
    = Minimized
    | Maximized


type Section
    = Blank
    | ArticleListSection ArticleListSection.Model
    | ArticleSection ArticleSection.Model


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
        -- TEMP: Add styles on top
        [ spinnerStyle
        , topBar <| SetAppState Minimized
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
    | ArticleListMsg ArticleListSection.Msg
    | ArticleListLoaded (Result Http.Error (List ArticleSummary))
    | ArticleMsg
    | ArticleLoaded (Result Http.Error Article)



-- UPDATE


getSectionView : Section -> Html Msg
getSectionView section =
    case section of
        Blank ->
            -- Show spinner here
            text ""

        ArticleListSection m ->
            Html.map ArticleListMsg <| ArticleListSection.view m

        ArticleSection m ->
            ArticleSection.view m


getSection : SectionState -> Section
getSection sectionState =
    case sectionState of
        Loaded section ->
            section

        TransitioningFrom section ->
            section


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
                            , TransitioningFrom (getSection model.sectionState)
                              -- TODO: Call API and retrive contextual support response
                            , Task.attempt ArticleListLoaded ArticleListSection.init
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

        ArticleListLoaded (Ok articleList) ->
            ( { model | sectionState = Loaded (ArticleListSection articleList) }, Cmd.none )

        ArticleListMsg aMsg ->
            case aMsg of
                ArticleListSection.LoadArticle articleId ->
                    ( { model | sectionState = TransitioningFrom (getSection model.sectionState) }
                    , Task.attempt ArticleLoaded <| ArticleSection.init articleId
                    )

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
