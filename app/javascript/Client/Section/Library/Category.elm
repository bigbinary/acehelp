module Section.Library.Category exposing (Model, Msg(..), init, initModel, update, view)

import Animation
import Data.Article exposing (..)
import Data.Category exposing (..)
import Data.Common exposing (..)
import Html exposing (..)
import Html.Attributes exposing (class, id)
import Html.Events exposing (onClick)
import Views.Error as Error exposing (errorMessageView)
import Views.FontAwesome as FontAwesome exposing (..)



-- MODEL


type alias Model =
    Maybe Category


init : Model -> ( Model, List (SectionCmd Msg) )
init category =
    ( category, [] )


initModel : Model
initModel =
    Nothing



-- initAnim : Animation.State
-- initAnim =
--     Animation.style popInInitialAnim
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
                    div [ id "content-wrapper" ] <|
                        div [ class "row-view" ] [ h1 [] [ text category.name ] ]
                            :: List.map
                                (\article ->
                                    div
                                        [ onClick <| LoadArticle article.id
                                        , class "selectable-row"
                                        ]
                                        [ span [ class "row-icon" ] [ FontAwesome.file_alt ]
                                        , span [ class "row-title" ] [ text article.title ]
                                        ]
                                )
                                category.articles

        Nothing ->
            text ""
