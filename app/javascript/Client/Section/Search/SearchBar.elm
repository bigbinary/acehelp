module Section.Search.SearchBar exposing (Model, Msg(..), init, initModel, requestSearch, update, view)

import Data.Article exposing (ArticleSummary)
import Data.Common exposing (..)
import GraphQL.Client.Http as GQLClient
import Html exposing (..)
import Html.Attributes as Attributes exposing (class, placeholder, style, type_)
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Reader exposing (Reader, run)
import Request.Article exposing (requestSearchArticles)
import Request.Helpers exposing (ApiKey, NodeEnv)
import Task exposing (Task)
import Views.FontAwesome as FontAwesome exposing (..)



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
    Html.form [ class "ah-search-bar", style "background-color" color, onSubmit OnSearch ]
        [ input
            [ type_ "text"
            , onInput OnSearchQueryInput
            , placeholder "Search for an Article"
            ]
            []
        , span [ onClick OnSearch, style "width" "40px" ] [ FontAwesome.search ]
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
