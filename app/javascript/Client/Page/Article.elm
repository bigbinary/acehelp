module Page.Article exposing (init, Model, view)

import Data.Article exposing (..)
import Request.Article exposing (..)
import Request.Helpers exposing (ApiKey, Context, NodeEnv)
import Html exposing (..)
import Html.Attributes exposing (id, class)
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
    div [ id "content-wrapper" ]
        [ div [ class "article-wrapper" ]
            [ h1 [] [ text article.title ]
            , div [ class "article-content" ]
                [ p [] [ text article.content ]
                ]
            ]
        ]
