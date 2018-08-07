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
import Request.Helpers exposing (..)
import Route
import Task exposing (Task)


-- MODEL


type alias Model =
    { id : String
    , name : Field String String
    , error : Maybe String
    }


initModel : CategoryId -> Model
initModel categoryId =
    { name = Field (validateEmpty "Name") ""
    , id = categoryId
    , error = Nothing
    }


init : CategoryId -> ( Model, Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error Category) )
init categoryId =
    ( initModel categoryId
    , requestCategoryById categoryId
    )



-- UPDATE


type Msg
    = CategoryNameInput CategoryName
    | CategoryLoaded (Result GQLClient.Error Category)
    | SaveCategory
    | UpdateCategoryResponse (Result GQLClient.Error Category)


update : Msg -> Model -> NodeEnv -> ApiKey -> ( Model, Cmd Msg )
update msg model nodeEnv organizationKey =
    case msg of
        CategoryLoaded (Ok category) ->
            ( { model
                | name = Field.update model.name category.name
                , id = category.id
              }
            , Cmd.none
            )

        CategoryLoaded (Err err) ->
            ( { model | error = Just "There was an error loading up the article" }
            , Cmd.none
            )

        CategoryNameInput categoryName ->
            ( { model
                | name = Field.update model.name categoryName
              }
            , Cmd.none
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
                    updateCategory model nodeEnv organizationKey
                else
                    ( { model | error = Just errors }, Cmd.none )

        UpdateCategoryResponse (Ok id) ->
            ( model, Route.modifyUrl <| Route.CategoryList organizationKey )

        UpdateCategoryResponse (Err error) ->
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
                , Html.Attributes.value <| Field.value model.name
                ]
                []
            ]
        , div []
            [ button
                [ type_ "submit"
                , class "button primary"
                ]
                [ text "Save" ]
            ]
        ]



-- TODO: Add request for category edit when backend is ready


categoryUpdateInputs : Model -> UpdateCategoryInputs
categoryUpdateInputs { id, name } =
    { id = id
    , name = Field.value name
    }


updateCategory : Model -> NodeEnv -> ApiKey -> ( Model, Cmd Msg )
updateCategory model nodeEnv organizationKey =
    let
        cmd =
            Task.attempt UpdateCategoryResponse
                (Reader.run requestUpdateCategory
                    ( nodeEnv, organizationKey, categoryUpdateInputs model )
                )
    in
        ( model, cmd )
