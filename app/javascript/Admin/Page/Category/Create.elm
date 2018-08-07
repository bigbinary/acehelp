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


init : ( Model, Cmd Msg )
init =
    ( initModel
    , Cmd.none
    )



-- UPDATE


type Msg
    = CategoryNameInput CategoryName
    | SaveCategory
    | SaveCategoryResponse (Result GQLClient.Error Category)


update : Msg -> Model -> NodeEnv -> ApiKey -> ( Model, Cmd Msg )
update msg model nodeEnv organizationKey =
    case msg of
        CategoryNameInput categoryName ->
            ( { model | name = Field.update model.name categoryName }, Cmd.none )

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
                    saveCategory model nodeEnv organizationKey
                else
                    ( { model | error = Just errors }, Cmd.none )

        SaveCategoryResponse (Ok id) ->
            ( { model
                | id = "0"
                , name = Field.update model.name ""
                , error = Nothing
              }
            , Route.modifyUrl <| Route.CategoryList organizationKey
            )

        SaveCategoryResponse (Err error) ->
            ( { model | error = Just (toString error) }, Cmd.none )



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


saveCategory : Model -> NodeEnv -> ApiKey -> ( Model, Cmd Msg )
saveCategory model nodeEnv organizationKey =
    let
        cmd =
            Task.attempt SaveCategoryResponse
                (Reader.run requestCreateCategory
                    ( nodeEnv, organizationKey, categroyCeateInputs model )
                )
    in
        ( model, cmd )
