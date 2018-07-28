module Page.Category.Create exposing (..)

import Http
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Admin.Data.Category exposing (..)
import Request.Helpers exposing (..)
import Field exposing (..)
import Field.ValidationResult exposing (..)
import Helpers exposing (..)


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
    | SaveCategoryResponse (Result Http.Error String)


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


saveCategory : Model -> NodeEnv -> ApiKey -> ( Model, Cmd Msg )
saveCategory model nodeEnv organizationKey =
    ( model, Cmd.none )
