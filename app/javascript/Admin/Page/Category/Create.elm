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
import Task exposing (Task)
import Admin.Data.ReaderCmd exposing (..)
import Page.UserNotification exposing (..)


-- MODEL


type alias Model =
    { id : String
    , name : Field String String
    }


initModel : Model
initModel =
    { id = "0"
    , name = Field (validateEmpty "Name") ""
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
    | SaveCategoryResponse (Result GQLClient.Error (Maybe Category))
    | NotifyError String


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
                        |> String.join ", "
            in
                if isAllValid fields then
                    saveCategory model
                else
                    update (NotifyError errors) model

        SaveCategoryResponse (Ok id) ->
            -- NOTE: Redirection handled in Main
            ( { model
                | id = "0"
                , name = Field.update model.name ""
              }
            , []
            )

        SaveCategoryResponse (Err error) ->
            update (NotifyError "There was an error while saving the Category") model

        NotifyError error ->
            -- NOTE: Handled in Main
            ( model, [] )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ div []
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
                [ type_ "button"
                , class "btn btn-primary"
                , onClick SaveCategory
                ]
                [ text "Submit" ]
            ]
        ]



-- TODO: Add request for category create when backend is ready


categroyCeateInputs : Model -> CreateCategoryInputs
categroyCeateInputs { name } =
    { name = Field.value name
    }


saveCategory : Model -> ( Model, List (ReaderCmd Msg) )
saveCategory model =
    let
        cmd =
            Strict <| Reader.map (Task.attempt SaveCategoryResponse) (requestCreateCategory <| categroyCeateInputs model)
    in
        ( model, [ cmd ] )
