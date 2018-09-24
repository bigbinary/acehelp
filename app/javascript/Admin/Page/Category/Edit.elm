module Page.Category.Edit exposing
    ( Model
    , Msg(..)
    , categoryUpdateInputs
    , init
    , initModel
    , update
    , updateCategory
    , view
    )

import Admin.Data.Category exposing (..)
import Admin.Data.ReaderCmd exposing (..)
import Admin.Request.Category exposing (..)
import Admin.Views.Common exposing (errorView)
import Field exposing (..)
import Field.ValidationResult exposing (..)
import GraphQL.Client.Http as GQLClient
import Helpers exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)



-- MODEL


type alias Model =
    { id : String
    , name : Field String String
    , errors : List String
    , success : Maybe String
    , status : String
    }


initModel : CategoryId -> Model
initModel categoryId =
    { name = Field (validateEmpty "Name") ""
    , id = categoryId
    , errors = []
    , success = Nothing
    , status = ""
    }


init : CategoryId -> ( Model, List (ReaderCmd Msg) )
init categoryId =
    ( initModel categoryId
    , [ Strict <| Reader.map (Task.attempt CategoryLoaded) (requestCategoryById categoryId) ]
    )



-- UPDATE


type Msg
    = CategoryNameInput CategoryName
    | CategoryLoaded (Result GQLClient.Error (Maybe Category))
    | SaveCategory
    | UpdateCategoryResponse (Result GQLClient.Error CategoryResponse)


update : Msg -> Model -> ( Model, List (ReaderCmd Msg) )
update msg model =
    case msg of
        CategoryLoaded (Ok receivedCategory) ->
            case receivedCategory of
                Just category ->
                    ( { model
                        | name = Field.update model.name category.name
                        , status = category.status
                        , id = category.id
                      }
                    , []
                    )

                Nothing ->
                    ( model, [] )

        CategoryLoaded (Err err) ->
            ( { model | errors = [ "There was an error while loading the article" ] }
            , []
            )

        CategoryNameInput categoryName ->
            ( { model
                | name = Field.update model.name categoryName
              }
            , []
            )

        SaveCategory ->
            let
                fields =
                    [ model.name ]

                errors =
                    validateAll fields
                        |> filterFailures
                        |> List.map
                            (\result ->
                                case result of
                                    Failed err ->
                                        err

                                    Passed _ ->
                                        "Unknown Error"
                            )
            in
            if isAllValid fields then
                updateCategory model

            else
                ( { model | errors = errors }, [] )

        UpdateCategoryResponse (Ok id) ->
            ( model, [] )

        UpdateCategoryResponse (Err error) ->
            ( { model | errors = [ "There was an error while updating the Category" ] }, [] )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ errorView model.errors
        , div []
            [ Maybe.withDefault (text "") <|
                Maybe.map
                    (\message ->
                        div
                            [ class "alert alert-success alert-dismissible fade show"
                            , attribute "role" "alert"
                            ]
                            [ text <| message
                            ]
                    )
                    model.success
            ]
        , div []
            [ label [] [ text "Category Name: " ]
            , input
                [ type_ "text"
                , placeholder "Enter name for category..."
                , onInput CategoryNameInput
                , Html.Attributes.value <| Field.value model.name
                ]
                []
            ]
        , div [ class "row" ]
            [ div [ class "col-sm-2" ]
                [ button
                    [ type_ "button"
                    , class "btn btn-primary"
                    , onClick SaveCategory
                    ]
                    [ text "Save" ]
                ]
            ]
        ]



-- TODO: Add request for category edit when backend is ready


categoryUpdateInputs : Model -> UpdateCategoryInputs
categoryUpdateInputs { id, name } =
    { id = id
    , name = Field.value name
    }


updateCategory : Model -> ( Model, List (ReaderCmd Msg) )
updateCategory model =
    let
        cmd =
            Strict <|
                Reader.map (Task.attempt UpdateCategoryResponse)
                    (requestUpdateCategory <|
                        categoryUpdateInputs model
                    )
    in
    ( model, [ cmd ] )
