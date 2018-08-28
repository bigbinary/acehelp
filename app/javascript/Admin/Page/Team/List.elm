module Page.Team.List exposing (..)

--import Http

import Admin.Data.Team exposing (..)
import Admin.Request.Team exposing (..)
import GraphQL.Client.Http as GQLClient
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)
import Admin.Data.ReaderCmd exposing (..)


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
    = TeamListLoaded (Result GQLClient.Error (List Team))
    | DeleteTeamMember String
    | DeleteTeamMemberResponse (Result GQLClient.Error (List Team))
    | OnAddTeamMemberClick


update : Msg -> Model -> ( Model, List (ReaderCmd Msg) )
update msg model =
    case msg of
        TeamListLoaded (Ok teamList) ->
            ( { model | teamList = teamList }, [] )

        TeamListLoaded (Err err) ->
            ( { model | error = Just "An error while fetching the Team list" }, [] )

        DeleteTeamMember teamMemberEmail ->
            deleteRecord model teamMemberEmail

        DeleteTeamMemberResponse (Ok teamList) ->
            ( { model | teamList = teamList }, [] )

        DeleteTeamMemberResponse (Err error) ->
            ( { model | error = Just "An error occured while deleting the Team Member" }, [] )

        OnAddTeamMemberClick ->
            -- NOTE: Handled in Main
            ( model, [] )



-- VIEW


view : Model -> Html Msg
view model =
    div
        [ id "feedback_list" ]
        [ div []
            [ Maybe.withDefault (text "") <|
                Maybe.map
                    (\err ->
                        div [ class "alert alert-danger alert-dismissible fade show", attribute "role" "alert" ]
                            [ text <| "Error: " ++ err
                            ]
                    )
                    model.error
            ]
        , button
            [ onClick OnAddTeamMemberClick
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
