module Page.Category.List exposing (..)

import Admin.Data.Category exposing (..)
import Admin.Request.Category exposing (..)
import GraphQL.Client.Http as GQLClient
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)
import Page.Helpers exposing (..)


-- MODEL


type alias Model =
    { categories : List Category
    , error : Maybe String
    }


initModel : Model
initModel =
    { categories = []
    , error = Nothing
    }


init : ( Model, List (PageCmd Msg) )
init =
    ( initModel
    , [ Reader.map (Task.attempt CategoriesLoaded) requestCategories ]
    )



-- UPDATE


type Msg
    = CategoriesLoaded (Result GQLClient.Error (List Category))
    | DeleteCategory CategoryId
    | DeleteCategoryResponse (Result GQLClient.Error CategoryId)
    | OnCreateCategoryClick
    | OnEditCategoryClick CategoryId


update : Msg -> Model -> ( Model, List (PageCmd Msg) )
update msg model =
    case msg of
        CategoriesLoaded (Ok categories) ->
            ( { model
                | categories = categories
              }
            , []
            )

        CategoriesLoaded (Err error) ->
            ( { model | error = Just (toString error) }, [] )

        DeleteCategory categoryId ->
            deleteCategoryById model categoryId

        DeleteCategoryResponse (Ok id) ->
            ( { model | categories = List.filter (\m -> m.id /= id) model.categories, error = Nothing }, [] )

        DeleteCategoryResponse (Err error) ->
            ( { model | error = Just (toString error) }, [] )

        OnCreateCategoryClick ->
            -- NOTE: Handled in Main
            ( model, [] )

        OnEditCategoryClick _ ->
            -- NOTE: Handled in Main
            ( model, [] )



-- VIEW


view : Model -> Html Msg
view model =
    div
        []
        [ div
            []
            [ Maybe.withDefault (text "") <|
                Maybe.map
                    (\err ->
                        div
                            [ class "alert alert-danger alert-dismissible fade show"
                            , attribute "role" "alert"
                            ]
                            [ text <| "Error: " ++ err ]
                    )
                    model.error
            ]
        , button
            [ onClick OnCreateCategoryClick
            , class "btn btn-primary"
            ]
            [ text "New Category" ]
        , div
            [ class "listingSection" ]
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
        [ class "listingRow" ]
        [ div
            [ class "textColumn" ]
            [ text category.name ]
        , div
            [ class "actionButtonColumn" ]
            [ button
                [ class "actionButton btn btn-primary"
                , onClick (OnEditCategoryClick category.id)
                ]
                [ text "Edit Category" ]
            ]
        , div
            [ class "actionButtonColumn" ]
            [ button
                [ class "actionButton btn btn-primary"
                , onClick (DeleteCategory category.id)
                ]
                [ text "Delete Category" ]
            ]
        ]


deleteCategoryById : Model -> CategoryId -> ( Model, List (PageCmd Msg) )
deleteCategoryById model categoryId =
    let
        cmd =
            (Reader.map (Task.attempt DeleteCategoryResponse) (deleteCategory categoryId))
    in
        ( model, [ cmd ] )
