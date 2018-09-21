module Page.Team.List exposing (Model, Msg(..), deleteRecord, init, initModel, row, update, view)

--import Http

import Admin.Data.ReaderCmd exposing (..)
import Admin.Data.Team exposing (..)
import Admin.Request.Helper exposing (ApiKey)
import Admin.Request.Team exposing (..)
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
    }


initModel : Model
initModel =
    { teamList = []
    , error = Nothing
    }


init : ( Model, List (ReaderCmd Msg) )
init =
    ( initModel
    , [ Strict <| Reader.map (Task.attempt TeamListLoaded) requestTeam ]
    )



-- UPDATE


type Msg
    = TeamListLoaded (Result GQLClient.Error (Maybe (List Team)))
    | DeleteTeamMember String
    | DeleteTeamMemberResponse (Result GQLClient.Error (Maybe (List Team)))


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

        DeleteTeamMember teamMemberEmail ->
            deleteRecord model teamMemberEmail

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
                [ onClick (DeleteTeamMember teamMember.email)
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
    ( model, [ cmd ] )
