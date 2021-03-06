module Page.Category.Create exposing
    ( Model
    , Msg(..)
    , categroyCreateInputs
    , init
    , initModel
    , saveCategory
    , update
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
import Page.UserNotification exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)



-- MODEL


type alias Model =
    { id : String
    , name : Field String String
    , errors : List String
    }


initModel : Model
initModel =
    { id = "0"
    , name = Field (validateEmpty "Name") ""
    , errors = []
    }


init : ( Model, List (ReaderCmd Msg) )
init =
    ( initModel
    , []
    )



-- UPDATE


type Msg
    = CategoryNameInput CategoryName
    | SaveCategory
    | SaveCategoryResponse (Result GQLClient.Error CategoryResponse)


update : Msg -> Model -> ( Model, List (ReaderCmd Msg) )
update msg model =
    case msg of
        CategoryNameInput categoryName ->
            ( { model | name = Field.update model.name categoryName }, [] )

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
                saveCategory model

            else
                ( { model | errors = errors }, [] )

        SaveCategoryResponse (Ok id) ->
            -- NOTE: Redirection handled in Main
            ( { model
                | id = "0"
                , name = Field.update model.name ""
              }
            , []
            )

        SaveCategoryResponse (Err error) ->
            ( { model | errors = [ "There was an error while saving the Category" ] }, [] )



-- VIEW


view : Model -> Html Msg
view model =
    Html.form [ onSubmit SaveCategory ]
        [ errorView model.errors
        , div []
            [ label [] [ text "Category Name: " ]
            , input
                [ type_ "text"
                , placeholder "Enter name for category..."
                , onInput CategoryNameInput
                , required True
                ]
                []
            ]
        , div []
            [ button
                [ type_ "submit"
                , class "btn btn-primary"
                ]
                [ text "Submit" ]
            ]
        ]



-- TODO: Add request for category create when backend is ready


categroyCreateInputs : Model -> CreateCategoryInputs
categroyCreateInputs { name } =
    { name = Field.value name
    }


saveCategory : Model -> ( Model, List (ReaderCmd Msg) )
saveCategory model =
    let
        cmd =
            Strict <|
                Reader.map (Task.attempt SaveCategoryResponse)
                    (requestCreateCategory <|
                        categroyCreateInputs model
                    )
    in
    ( model, [ cmd ] )
