module Page.Category.List exposing (..)

import Admin.Data.Category exposing (..)
import Admin.Request.Category exposing (..)
import Admin.Request.Helper exposing (..)
import GraphQL.Client.Http as GQLClient
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Navigation exposing (..)
import Reader exposing (Reader)
import Route
import Task exposing (Task)


-- MODEL


type alias Model =
    { categories : List Category
    , error : Maybe String
    , organizationKey : String
    }


initModel : ApiKey -> Model
initModel organizationKey =
    { categories = []
    , error = Nothing
    , organizationKey = organizationKey
    }


init : ApiKey -> ( Model, Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error (List Category)) )
init organizationKey =
    ( initModel organizationKey
    , requestCategories
    )

-- UPDATE


type Msg
    = CategoriesLoaded (Result GQLClient.Error (List Category))
    | Navigate Route.Route
    | DeleteCategory String
    | DeleteCategoryResponse (Result GQLClient.Error CategoryId)


update : Msg -> Model -> NodeEnv -> ApiKey -> ( Model, Cmd Msg )
update msg model nodeEnv organizationKey =
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

        DeleteCategory categoryId ->
            deleteCategoryById model nodeEnv organizationKey { id = categoryId }

        DeleteCategoryResponse (Ok id) ->
            let
                categories =
                    List.filter (\m -> m.id /= id) model.categories
            in
                ( { model | categories = categories }, Cmd.none )

        DeleteCategoryResponse (Err error) ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div
        []
        [ div
            [ class "buttonDiv" ]
            [ Html.a
                [ onClick (Navigate <| Route.CategoryCreate model.organizationKey)
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
    div
        []
        [ span
            [ class "deleteIcon"
            , onClick (DeleteCategory category.id)
            ]
            [ text "x" ]
        , span
            [ onClick <| Navigate <| Route.CategoryEdit category.id
            ]
            [ text category.name ]
        ]


deleteCategoryById : Model -> NodeEnv -> ApiKey -> DeleteCategoryInput -> ( Model, Cmd Msg )
deleteCategoryById model nodeEnv apiKey categoryId =
    let
        cmd =
            Task.attempt DeleteCategoryResponse (Reader.run deleteCategory ( nodeEnv, apiKey, categoryId ))
    in
        ( model, cmd )
