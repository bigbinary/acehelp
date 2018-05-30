module Page.Article exposing (init, Model, view)

import Data.Article exposing (..)
import Request.Article exposing (..)
import Html exposing (..)
import Http
import Task


-- MODEL


type alias Model =
    Article


init : ArticleId -> Task.Task Http.Error Article
init =
    Http.toTask << requestArticle



-- UPDATE
-- VIEW


view : Model -> Html msg
view article =
    div []
        [ h2 [] [ text article.title ]
        , p [] [ text article.content ]
        ]
