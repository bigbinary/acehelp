module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Http
-- import Element exposing (el, text,  column, layout, screen)
-- import Element.Attributes exposing (width, height, paddingXY, spacing, px, fill, alignRight, verticalCenter)
-- import Element.Events exposing (onClick)
-- import Views.Style exposing (stylesheet, AHStyle, renderAnim)
import Views.Container exposing (rowView, closeButton)
import Data.Article exposing (..)
import Request.Article exposing (..)
import Animation

-- MODEL


type AppState
  = Minimized
  | Maximized


type alias Model =
  { articles : List ArticleShort
  , containerAnim: Animation.State
  , currentAppState: AppState
  }

-- INIT

initContainerAnim =
        [ Animation.opacity 0
        , Animation.right <| Animation.px -770
        ]

init : (Model, Cmd Message)
init =
  ({ articles = []
  , containerAnim = Animation.style initContainerAnim
  , currentAppState = Minimized
  }, getArticles)

-- VIEW


-- minimizedView : Html Message
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


minimizedView : Html Message
minimizedView =
  div [ style
        [ ("position", "fixed")
        , ("width", "100px")
        , ("height", "100px")
        , ("top", "50%")
        , ("right", "0px")
        , ("transform", "translateY(-50%)")
        , ("background-color", "rgb(60, 170, 249)")
        , ("border-radius", "50%")
        , ("text-align", "center")
        , ("color", "#fff")
        , ("font-size", "80px")
        , ("font-family", "proxima-nova, Arial, sans-serif")
        ]
      , onClick (SetAppState Maximized)
      ] [ text "?" ]


-- maximizedView : Model -> Html Message
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

maximizedView : Model -> Html Message
maximizedView model =
  div (List.concat [ Animation.render model.containerAnim
        , [ style 
            [ ("position", "fixed")
            , ("top", "0")
            , ("background", "#fff")
            , ("height", "100%")
            , ("width", "720px")
            , ("box-shadow", "0 0 50px 0px rgb(153, 153, 153)")
            , ("font-family", "proxima-nova, Arial, sans-serif")
            ]
          ]
        ]
      )
      [ topBar
      , articleListView model
      ]


topBar : Html Message
topBar =
  rowView [("background-color", "rgb(60, 170, 249)")]
    [ span 
      [ style 
        [ ("text-align", "center")
        , ("display", "block")
        , ("color", "#fff")
        ]
      ] [ text "Ace Help" ]
    , div 
        [ style
          [ ("position", "absolute")
          , ("top", "0")
          , ("bottom", "0")
          , ("right", "35px")
          , ("line-height", "0")
          ]
        , onClick <| SetAppState Minimized
        ] 
        [ closeButton ]
    ]

articleListView : Model -> Html Message
articleListView model =
  rowView []
    (List.map (\a ->
              div [] [text a.title]
              ) model.articles)

view : Model -> Html Message
view model =
  case model.currentAppState of
    Minimized -> minimizedView
    Maximized -> maximizedView model

-- MESSAGE

type Message
  = Animate Animation.Msg
  | SetAppState AppState
  | ArticlesReceived (Result Http.Error (List ArticleShort))

-- UPDATE


getArticles : Cmd Message
getArticles =
  Http.send ArticlesReceived(requestArticles)



update : Message -> Model -> (Model, Cmd Message)
update message model =
  case message of
    Animate aniMsg ->
      ({ model
      | containerAnim = Animation.update aniMsg model.containerAnim
      }, Cmd.none)

    SetAppState s ->
      let
          anim =
            case s of
              Maximized ->
                Animation.interrupt
                  [ Animation.to 
                    [ Animation.opacity 1
                    , Animation.right <| Animation.px 0
                    ]
                  ]
                  model.containerAnim
              Minimized -> 
                Animation.interrupt
                  [ Animation.to initContainerAnim ] model.containerAnim
      in
          
        ({ model | currentAppState = s, containerAnim = anim }, Cmd.none)
    
    ArticlesReceived (Ok articleList) -> 
      ({model | articles = articleList}, Cmd.none)
    _ ->
      (model, Cmd.none)

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Message
subscriptions model =
  Animation.subscription Animate [ model.containerAnim ]

-- MAIN

main : Program Never Model Message
main =
  Html.program
    {
      init = init,
      view = view,
      update = update,
      subscriptions = subscriptions
    }
