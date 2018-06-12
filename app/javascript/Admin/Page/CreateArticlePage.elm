module Page.CreateArticlePage exposing (..)

import Html exposing (..)
import Data.ArticleData exposing (..)


-- Model


type alias Model =
    { article : Maybe Article
    , articleId : ArticleId
    }


init : ( Model, Cmd Msg )
init =
    ( { article = Nothing
      , articleId = 0
      }
    , Cmd.none
    )



-- Update


type Msg
    = NewArticle
    | ShowArticle ArticleId
    | TitleInput String
    | ContentInput String
    | KeywordsInput String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        _ ->
            ( model, Cmd.none )



-- View


view : Model -> Html Msg
view model =
    div [] [ text "creat Article Page" ]
