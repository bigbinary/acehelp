module Section.Library.Category exposing (..)

import Data.Category exposing (..)
import Data.Article exposing (..)
import Data.Common exposing (..)
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
import Views.Error exposing (errorMessageView)
import GraphQL.Client.Http as GQLClient
import Views.Error as Error


-- MODEL


type alias Model =
    Maybe Category


init : Model -> ( Model, List (SectionCmd Msg) )
init category =
    ( category, [] )


initModel : Model
initModel =
    Nothing


initAnim : Animation.State
initAnim =
    Animation.style popInInitialAnim



-- UPDATE


type Msg
    = LoadArticle ArticleId


update : Msg -> Model -> ( Model, List (SectionCmd Msg) )
update msg model =
    case msg of
        LoadArticle _ ->
            ( model, [] )



-- VIEW


view : Model -> Html Msg
view model =
    case model of
        Just category ->
            case category.articles of
                [] ->
                    errorMessageView
                        (text "")
                        (text "This Category seems to be empty at this moment")
                        (span []
                            [ text "Check back again later!"
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
                            category.articles
                        )

        Nothing ->
            text ""
