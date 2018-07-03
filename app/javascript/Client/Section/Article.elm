module Section.Article exposing (init, Model, view, defaultModel)

import Data.Article exposing (..)
import Request.Article exposing (..)
import Request.Helpers exposing (ApiKey, Context, NodeEnv)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Task
import Reader exposing (Reader)
import FontAwesome.Solid as SolidIcon


-- MODEL


type FeedBack
    = Positive
    | Negative
    | NoFeedback


type alias Model =
    { article : Article
    , feedback : FeedBack
    }


init : Reader ( NodeEnv, ApiKey, Context, ArticleId ) (Task.Task Http.Error ArticleResponse)
init =
    requestArticle


defaultModel : Article -> Model
defaultModel article =
    { article = article
    , feedback = NoFeedback
    }



-- UPDATE
-- VIEW


view : Model -> Html msg
view model =
    let
        article =
            model.article

        feebackView =
            case model.feedback of
                Positive ->
                    positiveView

                Negative ->
                    negativeView

                NoFeedback ->
                    didThisHelpView
    in
        div [ id "content-wrapper" ]
            [ div [ class "article-wrapper" ]
                [ h1 [] [ text article.title ]
                , div [ class "article-content" ]
                    [ p [] [ text article.content ]
                    ]
                , feebackView
                ]
            ]


didThisHelpView : Html msg
didThisHelpView =
    div [ class "did-this-help" ]
        [ span [] [ text "Did this help?" ]
        , div [ class "thumbs thumbs-up" ] [ SolidIcon.thumbs_up ]
        , div [ class "thumbs thumbs-down" ] [ SolidIcon.thumbs_down ]
        ]


positiveView : Html msg
positiveView =
    div [ class "did-this-help" ]
        [ span [] [ text "Great! Love it!" ] ]


negativeView : Html msg
negativeView =
    div [ class "did-this-help article-feedback" ]
        [ span []
            [ text "Please tell us what you are looking for."
            , text " If you enter your email then this would create a support ticket and we would get back to you soon"
            ]
        , textarea [ placeholder "Your comments" ] []
        , input [ type_ "text", placeholder "Your Email" ] []
        , input [ type_ "text", placeholder "Your Name" ] []
        ]
