module Page.Category.Create exposing (..)

import Http
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Data.CategoryData exposing (..)
import Request.Helpers exposing (..)


-- MODEL


type alias Model =
    { id : Int
    , name : String
    , nameError : Maybe String
    , error : Maybe String
    }


initModel : Model
initModel =
    { id = 0
    , name = ""
    , nameError = Nothing
    , error = Nothing
    }


init : ( Model, Cmd Msg )
init =
    ( initModel
    , Cmd.none
    )



-- UPDATE


type Msg
    = CategoryNameInput CategoryName
    | SaveCategory
    | SaveCategoryResponse (Result Http.Error String)


update : Msg -> Model -> NodeEnv -> ApiKey -> ( Model, Cmd Msg )
update msg model nodeEnv organizationKey =
    case msg of
        CategoryNameInput categoryName ->
            ( { model | name = categoryName }, Cmd.none )

        SaveCategory ->
            let
                updatedModel =
                    validate model
            in
                if isValid updatedModel then
                    saveCategory updatedModel nodeEnv organizationKey
                else
                    ( updatedModel, Cmd.none )

        SaveCategoryResponse (Ok id) ->
            ( { model
                | id = 0
                , name = ""
                , error = Nothing
              }
            , Cmd.none
            )

        SaveCategoryResponse (Err error) ->
            let
                errorMsg =
                    case error of
                        Http.BadStatus response ->
                            response.body

                        _ ->
                            "Error while saving Category"
            in
                ( { model
                    | error = Just errorMsg
                  }
                , Cmd.none
                )



-- VIEW


view : Model -> Html Msg
view model =
    Html.form
        [ onSubmit SaveCategory ]
        [ div []
            [ label [] [ text "Category Name: " ]
            , input
                [ type_ "text"
                , placeholder "Enter name for category..."
                , value model.name
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


validate : Model -> Model
validate model =
    model
        |> validateCategoryName


validateCategoryName : Model -> Model
validateCategoryName model =
    if String.isEmpty model.name then
        { model
            | nameError = Just "Category name is required"
        }
    else
        { model
            | nameError = Nothing
        }


isValid : Model -> Bool
isValid model =
    model.nameError
        == Nothing



-- TODO: Add request for category create when backend is ready


saveCategory : Model -> NodeEnv -> ApiKey -> ( Model, Cmd Msg )
saveCategory model nodeEnv organizationKey =
    ( model, Cmd.none )
