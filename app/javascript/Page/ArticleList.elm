module Page.ArticleList exposing (initAnim, Msg(..), Model, view, noArticles)

import Data.Category exposing (CategoryId)
import Data.Article exposing (..)
import Views.Container exposing (rowView, popInInitialAnim)
import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (style)
import Animation


-- MODEL


type alias Model =
    { id : CategoryId
    , articles : List ArticleSummary
    }


noArticles : List ArticleSummary
noArticles =
    []


initAnim : Animation.State
initAnim =
    Animation.style popInInitialAnim



-- UPDATE


type Msg
    = LoadArticle ArticleId


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        _ ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    rowView []
        (List.map
            (\a ->
                div
                    [ onClick <| LoadArticle a.id
                    , style [ ( "cursor", "pointer" ) ]
                    ]
                    [ text a.title ]
            )
            model.articles
        )
