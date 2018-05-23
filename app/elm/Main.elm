module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Http


-- import Element exposing (el, text,  column, layout, screen)
-- import Element.Attributes exposing (width, height, paddingXY, spacing, px, fill, alignRight, verticalCenter)
-- import Element.Events exposing (onClick)
-- import Views.Style exposing (stylesheet, AHStyle, renderAnim)

import Page.ArticleList as ArticleListSection
import Views.Container exposing (topBar, closeButton)
import Data.Article exposing (..)
import Request.Article exposing (..)
import Animation


-- MODEL


type AppState
    = Minimized
    | Maximized


type alias Model =
    { articles : ArticleListSection.Model
    , containerAnim : Animation.State
    , currentAppState : AppState
    }



-- INIT


initAnim : List Animation.Property
initAnim =
    [ Animation.opacity 0
    , Animation.right <| Animation.px -770
    ]


init : ( Model, Cmd Msg )
init =
    ( { articles = ArticleListSection.noArticles
      , containerAnim = Animation.style initAnim
      , currentAppState = Minimized
      }
    , Cmd.none
    )



-- VIEW
-- minimizedView : Html Msg
-- minimizedView =
--   layout stylesheet
--     <| screen
--     <| el Views.Style.AHButton
--           [ verticalCenter
--           , alignRight
--           , width (px 100)
--           , height (px 100)
--           , onClick (SetAppState Maximized)
--           ]
--           (Element.text "?")


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



-- maximizedView : Model -> Html Msg
-- maximizedView model =
-- layout stylesheet
--   <| screen
--   <| el Views.Style.MainContainerStyle
--       ( renderAnim model.containerAnim
--           [ width (px 720)
--           , height fill
--           ]
--       )
--       ( column Views.Style.StackStyle
--           [ width fill
--           , height fill
--           , paddingXY 30 10
--           ]
--           []
--       )


maximizedView : Model -> Html Msg
maximizedView model =
    div
        (List.concat
            [ Animation.render model.containerAnim
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
        , ArticleListSection.view model.articles |> Html.map ArticleListMsg
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
    | ArticleListReceived (Result Http.Error (List ArticleShort))
    | ArticleReceived (Result Http.Error Article)



-- UPDATE


getArticleList : Cmd Msg
getArticleList =
    Http.send ArticleListReceived (requestArticleList)


getArticle : ArticleId -> Cmd Msg
getArticle aId =
    Http.send ArticleReceived (requestArticle aId)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Animate aniMsg ->
            ( { model
                | containerAnim = Animation.update aniMsg model.containerAnim
              }
            , Cmd.none
            )

        SetAppState s ->
            let
                ( anim, cmd ) =
                    case s of
                        Maximized ->
                            ( Animation.interrupt
                                [ Animation.to
                                    [ Animation.opacity 1
                                    , Animation.right <| Animation.px 0
                                    ]
                                ]
                                model.containerAnim
                            , getArticleList
                            )

                        Minimized ->
                            ( Animation.interrupt
                                [ Animation.to initAnim ]
                                model.containerAnim
                            , Cmd.none
                            )
            in
                ( { model | currentAppState = s, containerAnim = anim }, cmd )

        ArticleListReceived (Ok articleList) ->
            ( { model | articles = articleList }, Cmd.none )

        _ ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Animation.subscription Animate [ model.containerAnim ]



-- MAIN


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
