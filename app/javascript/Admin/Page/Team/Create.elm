module Page.Team.Create exposing (..)

import Admin.Data.Team exposing (..)
import Admin.Request.Team exposing (..)
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
    { error : Maybe String
    , success : Maybe String
    , firstName : String
    , lastName : String
    , email : Field String String
    }


initModel : Model
initModel =
    { error = Nothing
    , success = Nothing
    , firstName = ""
    , lastName = ""
    , email = Field (validateEmpty "Email") ""
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
    | SaveTeamResponse (Result GQLClient.Error Team)


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
                        |> String.join ", "
            in
                if isAllValid fields then
                    save model
                else
                    ( { model | error = Just errors }, [] )

        SaveTeamResponse (Ok id) ->
            ( { model | success = Just "Team member added" }, [] )

        SaveTeamResponse (Err error) ->
            ( { model | error = Just (toString error) }, [] )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ div []
            [ Maybe.withDefault (text "") <|
                Maybe.map
                    (\err ->
                        div
                            [ class "alert alert-danger alert-dismissible fade show"
                            , attribute "role" "alert"
                            ]
                            [ text <| "Error: " ++ err
                            ]
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
            [ label [] [ text "First Name : " ]
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
            [ label [] [ text "Email : " ]
            , input
                [ type_ "text"
                , placeholder "Email"
                , onInput EmailInput
                ]
                []
            ]
        , button
            [ type_ "button", class "btn btn-primary", onClick SaveTeam ]
            [ text "Save Member" ]
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
