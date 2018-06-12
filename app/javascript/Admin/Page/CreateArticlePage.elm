module Page.CreateArticlePage exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Data.ArticleData exposing (..)


-- Model


type alias Model =
    { article : Maybe Article
    , title : String
    , desc : String
    , keywords : String
    , articleId : ArticleId
    }


init : ( Model, Cmd Msg )
init =
    ( { article = Nothing
      , title = ""
      , desc = ""
      , keywords = ""
      , articleId = 0
      }
    , Cmd.none
    )



-- Update


type Msg
    = NewArticle
    | ShowArticle ArticleId
    | TitleInput String
    | DescInput String
    | KeywordsInput String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TitleInput title ->
            ( { model | title = title }, Cmd.none )

        DescInput desc ->
            ( { model | desc = desc }, Cmd.none )

        KeywordsInput keywords ->
            ( { model | keywords = keywords }, Cmd.none )

        _ ->
            ( model, Cmd.none )



-- View


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ Html.form
            []
            [ div []
                [ label [] [ text "Title: " ]
                , input
                    [ placeholder "Title..."
                    , onInput TitleInput
                    , value model.title
                    , type_ "text"
                    ]
                    []
                ]
            , div []
                [ label [] [ text "Description: " ]
                , textarea
                    [ placeholder "Short description about article..."
                    , onInput DescInput
                    , value model.desc
                    ]
                    []
                ]
            , div []
                [ label [] [ text "Keywords: " ]
                , input
                    [ placeholder "Keywords..."
                    , onInput KeywordsInput
                    , value model.keywords
                    , type_ "text"
                    ]
                    []
                ]
            , div []
                [ button [ type_ "submit", class "button primary" ] [ text "Submit" ]
                ]
            ]
        ]
