module Section.ArticleList exposing (init, initAnim, Msg(..), Model, view)

import Data.Category exposing (CategoryId)
import Data.Article exposing (..)
import Request.Article exposing (..)
import Request.Helpers exposing (..)
import Views.Container exposing (popInInitialAnim)
import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (id, class)
import Animation
import Task exposing (Task)
import Reader exposing (Reader)
import FontAwesome.Solid as SolidIcon
import Section.Error exposing (errorMessageView)
import GraphQL.Client.Http as GQLClient


-- MODEL


type alias Model =
    { id : Maybe CategoryId
    , articles : List ArticleSummary
    }


init : Context -> Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error (List ArticleSummary))
init =
    requestArticleList


initAnim : Animation.State
initAnim =
    Animation.style popInInitialAnim



-- UPDATE


type Msg
    = LoadArticle ArticleId
    | OpenLibrary


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        _ ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    case model.articles of
        [] ->
            errorMessageView
                (text "")
                (text "We could not find relevant articles for you at this moment")
                (span []
                    [ text "You can check out our "
                    , a [ onClick OpenLibrary ]
                        [ text "Library" ]
                    , text " or Search for an article"
                    ]
                )

        _ ->
            div [ id "content-wrapper" ]
                (List.map
                    (\article ->
                        div
                            [ onClick <| LoadArticle article.id
                            , class "selectable-row"
                            ]
                            [ span [ class "row-icon" ] [ SolidIcon.file_alt ]
                            , span [ class "row-title" ] [ text article.title ]
                            ]
                    )
                    model.articles
                )
