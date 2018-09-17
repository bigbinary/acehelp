module Section.Library.Library exposing (Model, Msg(..), getCategoryWithId, init, initModel, update, view)

import Animation
import Data.Category exposing (..)
import Data.Common exposing (..)
import GraphQL.Client.Http as GQLClient
import Html exposing (..)
import Html.Attributes exposing (class, id)
import Html.Events exposing (onClick)
import Reader
import Request.Category exposing (..)
import Request.Helpers exposing (ApiKey, Context, NodeEnv)
import Task
import Views.Error as Error
import Views.FontAwesome as FontAwesome exposing (..)



-- MODEL


type alias Model =
    Result GQLClient.Error (List Category)


init : ( Model, List (SectionCmd Msg) )
init =
    ( Ok [], [ Strict <| Reader.map (Task.attempt CategoryListLoaded) requestAllCategories ] )


initModel : Model
initModel =
    Ok []



-- initAnim : Animation.State
-- initAnim =
--     Animation.style popInInitialAnim
-- UPDATE


type Msg
    = LoadCategory CategoryId
    | CategoryListLoaded (Result GQLClient.Error (List Category))


update : Msg -> Model -> ( Model, List (SectionCmd Msg) )
update msg model =
    case msg of
        LoadCategory categoryId ->
            ( model, [] )

        CategoryListLoaded response ->
            ( response, [] )



-- VIEW


view : Model -> Html Msg
view model =
    case model of
        Ok categories ->
            div [ id "content-wrapper" ]
                (List.map
                    (\category ->
                        div
                            [ onClick <| LoadCategory category.id
                            , class "clickable selectable-row"
                            ]
                            [ span [ class "row-icon" ] [ FontAwesome.folder ]
                            , span [ class "row-title" ] [ text category.name ]
                            ]
                    )
                    categories
                )

        Err error ->
            Error.view error


getCategoryWithId : CategoryId -> Model -> Maybe Category
getCategoryWithId categoryId categoryList =
    List.head <|
        case categoryList of
            Ok categories ->
                List.filter
                    (\category -> category.id == categoryId)
                    categories

            err ->
                []
