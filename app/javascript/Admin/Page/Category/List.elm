module Page.Category.List exposing
    ( Model
    , Msg(..)
    , categoryRow
    , categoryStatusButton
    , deleteCategoryById
    , init
    , initModel
    , update
    , updateCategoryStatus
    , view
    )

import Admin.Data.Category exposing (..)
import Admin.Data.Common exposing (..)
import Admin.Data.ReaderCmd exposing (..)
import Admin.Data.Status exposing (..)
import Admin.Request.Category exposing (..)
import Admin.Request.Helper exposing (ApiKey)
import Admin.Views.Common exposing (..)
import Dialog
import GraphQL.Client.Http as GQLClient
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Page.Article.Common exposing (statusToButtonText)
import Reader exposing (Reader)
import Route exposing (..)
import Task exposing (Task)



-- MODEL


type alias Model =
    { categories : List Category
    , error : Maybe String
    , showDeleteCategoryConfirmation : Acknowledgement CategoryId
    }


initModel : Model
initModel =
    { categories = []
    , error = Nothing
    , showDeleteCategoryConfirmation = No
    }


init : ( Model, List (ReaderCmd Msg) )
init =
    ( initModel
    , [ Strict <| Reader.map (Task.attempt CategoriesLoaded) requestCategories ]
    )



-- UPDATE


type Msg
    = CategoriesLoaded (Result GQLClient.Error (Maybe (List Category)))
    | OnDeleteCategory CategoryId
    | DeleteCategoryResponse (Result GQLClient.Error (Maybe CategoryId))
    | UpdateCategoryStatus CategoryId AvailabilityStatus
    | AcknowledgeDelete (Acknowledgement CategoryId)


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

        OnDeleteCategory categoryId ->
            ( { model | showDeleteCategoryConfirmation = Yes categoryId }, [] )

        AcknowledgeDelete (Yes categoryId) ->
            deleteCategoryById model categoryId

        AcknowledgeDelete No ->
            ( { model | showDeleteCategoryConfirmation = No }, [] )

        DeleteCategoryResponse (Ok catId) ->
            case catId of
                Just id ->
                    ( { model
                        | categories = List.filter (\m -> m.id /= id) model.categories
                        , error = Nothing
                      }
                    , []
                    )

                Nothing ->
                    ( model, [] )

        DeleteCategoryResponse (Err error) ->
            ( { model | error = Just "An error occured when deleting the Category" }, [] )

        UpdateCategoryStatus categoryId status ->
            updateCategoryStatus model categoryId status



-- VIEW


view : ApiKey -> Model -> Html Msg
view orgKey model =
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
        , a
            [ href <| routeToString <| CategoryCreate orgKey
            , class "btn btn-primary"
            ]
            [ text "+ Category" ]
        , div
            [ class "listingSection" ]
            (List.map
                (\category ->
                    categoryRow orgKey category
                )
                model.categories
            )
        , Dialog.view <|
            case model.showDeleteCategoryConfirmation of
                Yes categoryId ->
                    Just
                        (dialogConfig
                            { onDecline = AcknowledgeDelete No
                            , title = "Delete Category"
                            , body = text "Are you sure you want to delete this Category?"
                            , onAccept = AcknowledgeDelete (Yes categoryId)
                            }
                        )

                No ->
                    Nothing
        ]


categoryRow : ApiKey -> Category -> Html Msg
categoryRow orgKey category =
    div
        [ class "listingRow" ]
        [ div
            [ class "textColumn" ]
            [ text category.name ]
        , div
            [ class "actionButtonColumn" ]
            [ a
                [ class "actionButton btn btn-primary"
                , href <| routeToString <| CategoryEdit orgKey category.id
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
                , onClick (OnDeleteCategory category.id)
                ]
                [ text "Delete Category" ]
            ]
        ]


deleteCategoryById : Model -> CategoryId -> ( Model, List (ReaderCmd Msg) )
deleteCategoryById model categoryId =
    let
        cmd =
            Strict <| Reader.map (Task.attempt DeleteCategoryResponse) (deleteCategory categoryId)
    in
    ( { model | showDeleteCategoryConfirmation = No }, [ cmd ] )


updateCategoryStatus : Model -> CategoryId -> AvailabilityStatus -> ( Model, List (ReaderCmd Msg) )
updateCategoryStatus model categoryId categoryStatus =
    let
        cmd =
            Strict <|
                Reader.map (Task.attempt CategoriesLoaded)
                    (requestUpdateCategoryStatus
                        categoryId
                        categoryStatus
                    )
    in
    ( model, [ cmd ] )


categoryStatusButton : Category -> Html Msg
categoryStatusButton category =
    button
        [ onClick (UpdateCategoryStatus category.id <| availablityStatusIso.reverseGet category.status)
        , class "actionButton btn btn-primary"
        ]
        [ text ("Mark " ++ (statusToButtonText <| availablityStatusIso.reverseGet category.status)) ]
