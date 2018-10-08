module Page.Team.List exposing (Model, Msg(..), deleteRecord, init, initModel, row, update, view)

--import Http

import Admin.Data.Common exposing (..)
import Admin.Data.ReaderCmd exposing (..)
import Admin.Data.Team exposing (..)
import Admin.Request.Helper exposing (ApiKey)
import Admin.Request.Team exposing (..)
import Admin.Views.Common exposing (..)
import Dialog
import GraphQL.Client.Http as GQLClient
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Reader exposing (Reader)
import Route exposing (..)
import Task exposing (Task)



-- MODEL


type alias Model =
    { teamList : List Team
    , error : Maybe String
    , showDeleteMemberConfirmation : Acknowledgement String
    }


initModel : Model
initModel =
    { teamList = []
    , error = Nothing
    , showDeleteMemberConfirmation = No
    }


init : ( Model, List (ReaderCmd Msg) )
init =
    ( initModel
    , [ Strict <| Reader.map (Task.attempt TeamListLoaded) requestTeam ]
    )



-- UPDATE


type Msg
    = TeamListLoaded (Result GQLClient.Error (Maybe (List Team)))
    | DeleteTeamMember (Acknowledgement String)
    | DeleteTeamMemberResponse (Result GQLClient.Error (Maybe (List Team)))
    | AcknowledgeDelete (Acknowledgement String)


update : Msg -> Model -> ( Model, List (ReaderCmd Msg) )
update msg model =
    case msg of
        TeamListLoaded (Ok teamList) ->
            case teamList of
                Just teams ->
                    ( { model | teamList = teams }, [] )

                Nothing ->
                    ( model, [] )

        TeamListLoaded (Err err) ->
            ( { model | error = Just "An error while fetching the Team list" }, [] )

        DeleteTeamMember (Yes teamMemberEmail) ->
            ( { model | showDeleteMemberConfirmation = Yes teamMemberEmail }, [] )

        DeleteTeamMember No ->
            ( { model | showDeleteMemberConfirmation = No }, [] )

        AcknowledgeDelete (Yes teamMemberEmail) ->
            deleteRecord model teamMemberEmail

        AcknowledgeDelete No ->
            ( { model | showDeleteMemberConfirmation = No }, [] )

        DeleteTeamMemberResponse (Ok teamList) ->
            case teamList of
                Just teams ->
                    ( { model | teamList = teams }, [] )

                Nothing ->
                    ( model, [] )

        DeleteTeamMemberResponse (Err error) ->
            ( { model | error = Just "An error occured while deleting the Team Member" }, [] )



-- VIEW


view : ApiKey -> Model -> Html Msg
view orgKey model =
    div
        [ id "feedback_list" ]
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
        , a
            [ href <| routeToString <| TeamMemberCreate orgKey
            , class "btn btn-primary"
            ]
            [ text " + Add Team Member " ]
        , div [ class "listingSection" ]
            (List.map
                (\teamMember ->
                    row teamMember
                )
                model.teamList
            )
        , Dialog.view <|
            case model.showDeleteMemberConfirmation of
                Yes emailId ->
                    Just
                        (dialogConfig
                            { onDecline = AcknowledgeDelete No
                            , title = "Remove Team Member"
                            , body = text "Are you sure you want to remove this Team Member?"
                            , onAccept = AcknowledgeDelete (Yes emailId)
                            }
                        )

                No ->
                    Nothing
        ]


row : Team -> Html Msg
row teamMember =
    div
        [ id teamMember.id
        , class "listingRow"
        ]
        [ div
            [ class "textColumn" ]
            [ text <| (teamMember.name ++ " | " ++ teamMember.email) ]
        , div
            [ class "actionButtonColumn" ]
            [ button
                [ onClick (DeleteTeamMember (Yes teamMember.email))
                , class "actionButton btn btn-primary deleteTeamMember"
                ]
                [ text "Remove Team Member" ]
            ]
        ]


deleteRecord : Model -> String -> ( Model, List (ReaderCmd Msg) )
deleteRecord model userEmail =
    let
        cmd =
            Strict <| Reader.map (Task.attempt TeamListLoaded) (removeTeamMember userEmail)
    in
    ( { model | showDeleteMemberConfirmation = No }, [ cmd ] )
