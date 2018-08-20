module Section.Article.SuggestedList exposing (..)

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
    Result GQLClient.Error (List ArticleSummary)


init : Context -> ( Model, List (SectionCmd Msg) )
init url =
    ( initModel, [ Strict <| Reader.map (Task.attempt ArticleListLoaded) (requestSuggestedArticles url) ] )


initModel : Model
initModel =
    Ok []


initAnim : Animation.State
initAnim =
    Animation.style popInInitialAnim



-- UPDATE


type Msg
    = LoadArticle ArticleId
    | OpenLibrary
    | ArticleListLoaded (Result GQLClient.Error (List ArticleSummary))


update : Msg -> Model -> ( Model, List (SectionCmd Msg) )
update msg model =
    case msg of
        ArticleListLoaded response ->
            ( response, [] )

        LoadArticle _ ->
            ( model, [] )

        OpenLibrary ->
            ( model, [] )



-- VIEW


view : Model -> Html Msg
view model =
    case model of
        Err error ->
            Error.view error

        Ok articles ->
            case articles of
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
                            articles
                        )
