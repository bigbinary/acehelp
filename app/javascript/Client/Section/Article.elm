module Section.Article exposing (init, Model, view)

import Data.Article exposing (..)
import Request.Article exposing (..)
import Request.Helpers exposing (ApiKey, Context, NodeEnv)
import Html exposing (..)
import Html.Attributes exposing (id, class)
import Http
import Task
import Reader exposing (Reader)
import FontAwesome.Solid as SolidIcon


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
            , didThisHelpView article
            ]
        ]


didThisHelpView : Model -> Html msg
didThisHelpView model =
    div [ class "did-this-help" ]
        [ span [] [ text "Did this help?" ]
        , div [ class "thumbs thumbs-up" ] [ SolidIcon.thumbs_up ]
        , div [ class "thumbs thumbs-down" ] [ SolidIcon.thumbs_down ]
        ]


yesItDidView : Html msg
yesItDidView =
    div [ class "did-this-help" ]
        [ span [] [ text "Great! Love it!" ] ]


noItDidNotView : Html msg
noItDidNotView =
    div [ class "did-this-help article-feedback" ]
        [ span [] [ text "Please tell us what you are looking for. If you enter your email then this would create a support ticket and we would get back to you soon" ] ]
