module Page.Article exposing (init, Model, view)

import Data.Article exposing (..)
import Request.Article exposing (..)
import Request.Helpers exposing (ApiKey, Context, NodeEnv)
import Html exposing (..)
import Http
import Task
import Reader exposing (Reader)


-- MODEL


type alias Model =
    Article


init : Reader ( NodeEnv, ApiKey, Context, ArticleId ) (Task.Task Http.Error ArticleResponse)
init =
    requestArticle



-- UPDATE
-- VIEW


view : Model -> Html msg
view article =
    div []
        [ h2 [] [ text article.title ]
        , p [] [ text article.content ]
        ]
