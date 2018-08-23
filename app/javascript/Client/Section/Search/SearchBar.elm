module Section.Search.SearchBar exposing (..)

import Html exposing (..)
import Html.Attributes as Attributes exposing (class, style, placeholder, type_)
import Html.Events exposing (onClick, onInput)
import Http
import Data.Article exposing (ArticleSummary)
import Request.Article exposing (requestSearchArticles)
import Request.Helpers exposing (NodeEnv, ApiKey)
import FontAwesome.Solid as SolidIcon
import Reader exposing (Reader, run)
import Task exposing (Task)
import Data.Common exposing (..)
import GraphQL.Client.Http as GQLClient


-- MODEL


type alias Model =
    String


initModel : Model
initModel =
    ""


init : ( Model, List (SectionCmd Msg) )
init =
    ( initModel, [] )



-- VIEW


type Msg
    = OnSearch
    | OnSearchQueryInput String
    | SearchResultsReceived (Result GQLClient.Error (List ArticleSummary))


view : Model -> String -> Html Msg
view model color =
    div [ class "ah-search-bar", style [ ( "background-color", color ) ] ]
        [ input
            [ type_ "text"
            , onInput OnSearchQueryInput
            , placeholder "Search for an Article"
            ]
            []
        , span [ onClick OnSearch ] [ SolidIcon.search ]
        ]



-- UPDATE


update : Msg -> Model -> ( Model, List (SectionCmd Msg) )
update msg model =
    case msg of
        OnSearch ->
            ( model
            , [ Strict <|
                    Reader.map (Task.attempt SearchResultsReceived)
                        (requestSearch model)
              ]
            )

        OnSearchQueryInput searchQuery ->
            ( String.trim searchQuery, [] )

        SearchResultsReceived (Ok articleListResponse) ->
            ( model, [] )

        SearchResultsReceived (Err articleListResponse) ->
            ( model, [] )


requestSearch : Model -> Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error (List ArticleSummary))
requestSearch =
    requestSearchArticles
