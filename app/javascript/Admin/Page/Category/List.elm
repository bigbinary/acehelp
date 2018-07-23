module Page.Category.List exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Navigation exposing (..)
import Route
import Data.CategoryData exposing (..)
import Request.CategoryRequest exposing (..)
import Request.RequestHelper exposing (..)
import Data.CommonData exposing (Error)
import Task exposing (Task)
import Reader exposing (Reader)
import GraphQL.Client.Http as GQLClient


-- MODEL


type alias Model =
    { categories : List Category
    , error : Error
    }


initModel : Model
initModel =
    { categories = []
    , error = Nothing
    }


init : ( Model, Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error (List Category)) )
init =
    ( initModel
    , requestCategories
    )



-- UPDATE


type Msg
    = CategoriesLoaded (Result GQLClient.Error (List Category))
    | Navigate Route.Route


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CategoriesLoaded (Ok categories) ->
            ( { model
                | categories = categories
              }
            , Cmd.none
            )

        CategoriesLoaded (Err error) ->
            ( { model | error = Just (toString error) }, Cmd.none )

        Navigate page ->
            model ! [ Navigation.newUrl (Route.routeToString page) ]



-- VIEW


view : Model -> Html Msg
view model =
    div
        []
        [ div
            [ class "buttonDiv" ]
            [ Html.a
                [ onClick (Navigate <| Route.CategoryCreate)
                , class "button primary"
                ]
                [ text "New Category" ]
            ]
        , div
            []
            (List.map
                (\category ->
                    categoryRow category
                )
                model.categories
            )
        ]


categoryRow : Category -> Html Msg
categoryRow category =
    div []
        [ text category.name ]
