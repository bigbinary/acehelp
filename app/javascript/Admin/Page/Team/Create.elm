module Page.Team.Create exposing (Model, Msg(..), init, initModel, save, update, view)

import Admin.Data.ReaderCmd exposing (..)
import Admin.Data.Team exposing (..)
import Admin.Request.Team exposing (..)
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
    { errors : List String
    , success : Maybe String
    , firstName : String
    , lastName : String
    , email : Field String String
    }


initModel : Model
initModel =
    { errors = []
    , success = Nothing
    , firstName = ""
    , lastName = ""
    , email = Field validateEmail ""
    }


init : ( Model, List (ReaderCmd Msg) )
init =
    ( initModel
    , []
    )



-- UPDATE


type Msg
    = FirstNameInput String
    | LastNameInput String
    | EmailInput String
    | SaveTeam
    | SaveTeamResponse (Result GQLClient.Error TeamResponse)


update : Msg -> Model -> ( Model, List (ReaderCmd Msg) )
update msg model =
    case msg of
        FirstNameInput firstName ->
            ( { model | firstName = firstName }, [] )

        LastNameInput lastName ->
            ( { model | lastName = lastName }, [] )

        EmailInput email ->
            ( { model | email = Field.update model.email email }, [] )

        SaveTeam ->
            let
                fields =
                    [ model.email ]

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
                save model

            else
                ( { model | errors = errors }, [] )

        SaveTeamResponse (Ok id) ->
            ( model, [] )

        SaveTeamResponse (Err error) ->
            ( { model | errors = [ "An error occured while saving the Team" ] }, [] )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ Html.form [ onSubmit SaveTeam ]
            [ errorView model.errors
            , div []
                [ label [] [ text "First Name: " ]
                , input
                    [ type_ "text"
                    , placeholder "First Name"
                    , onInput FirstNameInput
                    ]
                    []
                ]
            , div []
                [ label [] [ text "Last Name: " ]
                , input
                    [ type_ "text"
                    , placeholder "Last Name"
                    , onInput LastNameInput
                    ]
                    []
                ]
            , div []
                [ label [] [ text "Email: " ]
                , input
                    [ type_ "text"
                    , placeholder "Email"
                    , onInput EmailInput
                    , required True
                    ]
                    []
                ]
            , button [ type_ "submit", class "btn btn-primary" ]
                [ text "Save Member" ]
            ]
        ]


save : Model -> ( Model, List (ReaderCmd Msg) )
save model =
    let
        cmd =
            Strict <|
                Reader.map (Task.attempt SaveTeamResponse)
                    (createTeamMember
                        { email = Field.value model.email
                        , firstName = model.firstName
                        , lastName = model.lastName
                        }
                    )
    in
    ( model, [ cmd ] )
