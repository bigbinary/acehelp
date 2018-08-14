module Page.Category.Create exposing (..)

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
import Request.Helpers exposing (..)
import Route
import Task exposing (Task)
import Page.Helpers exposing (..)


-- MODEL


type alias Model =
    { id : String
    , name : Field String String
    , error : Maybe String
    }


initModel : Model
initModel =
    { id = "0"
    , name = Field (validateEmpty "Name") ""
    , error = Nothing
    }


init : ( Model, List (PageCmd Msg) )
init =
    ( initModel
    , []
    )



-- UPDATE


type Msg
    = CategoryNameInput CategoryName
    | SaveCategory
    | SaveCategoryResponse (Result GQLClient.Error Category)


update : Msg -> Model -> ( Model, List (PageCmd Msg) )
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
                        |> String.join ", "
            in
                if isAllValid fields then
                    saveCategory model
                else
                    ( { model | error = Just errors }, [] )

        SaveCategoryResponse (Ok id) ->
            ( { model
                | id = "0"
                , name = Field.update model.name ""
                , error = Nothing
              }
            , []
            )

        SaveCategoryResponse (Err error) ->
            ( { model | error = Just (toString error) }, [] )



-- VIEW


view : Model -> Html Msg
view model =
    Html.form
        [ onSubmit SaveCategory ]
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
            [ label [] [ text "Category Name: " ]
            , input
                [ type_ "text"
                , placeholder "Enter name for category..."
                , onInput CategoryNameInput
                ]
                []
            ]
        , div []
            [ button
                [ type_ "submit"
                , class "button primary"
                ]
                [ text "Submit" ]
            ]
        ]



-- TODO: Add request for category create when backend is ready


categroyCeateInputs : Model -> CreateCategoryInputs
categroyCeateInputs { name } =
    { name = Field.value name
    }


saveCategory : Model -> ( Model, List (PageCmd Msg) )
saveCategory model =
    let
        cmd =
            Reader.map (Task.attempt SaveCategoryResponse) (requestCreateCategory <| categroyCeateInputs model)
    in
        ( model, [ cmd ] )
