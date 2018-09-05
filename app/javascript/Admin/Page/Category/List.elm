module Page.Category.List exposing (..)

import Admin.Data.Category exposing (..)
import Admin.Request.Category exposing (..)
import GraphQL.Client.Http as GQLClient
import Page.Article.Common exposing (statusToButtonText)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)
import Admin.Data.ReaderCmd exposing (..)
import Admin.Data.Status exposing (..)


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


init : ( Model, List (ReaderCmd Msg) )
init =
    ( initModel
    , [ Strict <| Reader.map (Task.attempt CategoriesLoaded) requestCategories ]
    )



-- UPDATE


type Msg
    = CategoriesLoaded (Result GQLClient.Error (Maybe (List Category)))
    | DeleteCategory CategoryId
    | DeleteCategoryResponse (Result GQLClient.Error (Maybe CategoryId))
    | OnCreateCategoryClick
    | OnEditCategoryClick CategoryId
    | UpdateCategoryStatus CategoryId AvailabilitySatus


update : Msg -> Model -> ( Model, List (ReaderCmd Msg) )
update msg model =
    case msg of
        CategoriesLoaded (Ok receivedCategories) ->
            case receivedCategories of
                Just categories ->
                    ( { model
                        | categories = categories
                      }
                    , []
                    )

                Nothing ->
                    ( model, [] )

        CategoriesLoaded (Err error) ->
            ( { model | error = Just "There was an error while loading the Categories" }, [] )

        DeleteCategory categoryId ->
            deleteCategoryById model categoryId

        DeleteCategoryResponse (Ok catId) ->
            case catId of
                Just id ->
                    ( { model | categories = List.filter (\m -> m.id /= id) model.categories, error = Nothing }, [] )

                Nothing ->
                    ( model, [] )

        DeleteCategoryResponse (Err error) ->
            ( { model | error = Just "An error occured when deleting the Category" }, [] )

        OnCreateCategoryClick ->
            -- NOTE: Handled in Main
            ( model, [] )

        OnEditCategoryClick _ ->
            -- NOTE: Handled in Main
            ( model, [] )

        UpdateCategoryStatus categoryId status ->
            updateCategoryStatus model categoryId status



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
            [ text "+ Category" ]
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
            [ categoryStatusButton category ]
        , div
            [ class "actionButtonColumn" ]
            [ button
                [ class "actionButton btn btn-primary"
                , onClick (DeleteCategory category.id)
                ]
                [ text "Delete Category" ]
            ]
        ]


deleteCategoryById : Model -> CategoryId -> ( Model, List (ReaderCmd Msg) )
deleteCategoryById model categoryId =
    let
        cmd =
            (Strict <| Reader.map (Task.attempt DeleteCategoryResponse) (deleteCategory categoryId))
    in
        ( model, [ cmd ] )


updateCategoryStatus : Model -> CategoryId -> AvailabilitySatus -> ( Model, List (ReaderCmd Msg) )
updateCategoryStatus model categoryId categoryStatus =
    let
        cmd =
            Strict <| Reader.map (Task.attempt CategoriesLoaded) (requestUpdateCategoryStatus categoryId <| availablityStatusIso.get categoryStatus)
    in
        ( model, [ cmd ] )


categoryStatusButton : Category -> Html Msg
categoryStatusButton category =
    button
        [ onClick (UpdateCategoryStatus category.id <| availablityStatusIso.reverseGet category.status)
        , class "actionButton btn btn-primary"
        ]
        [ text ("Mark " ++ (statusToButtonText <| availablityStatusIso.reverseGet category.status)) ]
