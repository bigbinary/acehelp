module Page.Category.Edit exposing (..)

import Admin.Data.Category exposing (..)
import Admin.Request.Category exposing (..)
import Field exposing (..)
import Field.ValidationResult exposing (..)
import GraphQL.Client.Http as GQLClient
import Helpers exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)
import Admin.Data.ReaderCmd exposing (..)


-- MODEL


type alias Model =
    { id : String
    , name : Field String String
    , error : Maybe String
    , success : Maybe String
    , status : String
    }


initModel : CategoryId -> Model
initModel categoryId =
    { name = Field (validateEmpty "Name") ""
    , id = categoryId
    , error = Nothing
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
    | UpdateCategoryResponse (Result GQLClient.Error (Maybe Category))


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
            ( { model | error = Just "There was an error loading up the article" }
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
                        |> String.join ", "
            in
                if isAllValid fields then
                    updateCategory model
                else
                    ( { model | error = Just errors }, [] )

        UpdateCategoryResponse (Ok id) ->
            ( model, [] )

        UpdateCategoryResponse (Err error) ->
            ( { model | error = Just "There was an error while updating the Category" }, [] )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ div []
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
        , div []
            [ Maybe.withDefault (text "") <|
                Maybe.map
                    (\message ->
                        div [ class "alert alert-success alert-dismissible fade show", attribute "role" "alert" ]
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
            Strict <| Reader.map (Task.attempt UpdateCategoryResponse) (requestUpdateCategory <| categoryUpdateInputs model)
    in
        ( model, [ cmd ] )
