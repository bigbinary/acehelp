module Page.Team.List exposing (..)

--import Http

import Admin.Data.Team exposing (..)
import Admin.Request.Team exposing (..)
import GraphQL.Client.Http as GQLClient
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Navigation exposing (..)
import Reader exposing (Reader)
import Request.Helpers exposing (ApiKey, NodeEnv)
import Route
import Task exposing (Task)


-- MODEL


type alias Model =
    { teamList : List Team
    , organizationKey : String
    , error : Maybe String
    }


initModel : ApiKey -> Model
initModel organizationKey =
    { teamList = []
    , organizationKey = organizationKey
    , error = Nothing
    }


init : ApiKey -> ( Model, Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error (List Team)) )
init organizationKey =
    ( initModel organizationKey
    , requestTeam
    )



-- UPDATE


type Msg
    = TeamListLoaded (Result GQLClient.Error (List Team))
    | Navigate Route.Route
    | DeleteTeamMember String
    | DeleteTeamMemberResponse (Result GQLClient.Error (List Team))


update : Msg -> Model -> ApiKey -> NodeEnv -> ( Model, Cmd Msg )
update msg model apiKey nodeEnv =
    case msg of
        TeamListLoaded (Ok teamList) ->
            ( { model | teamList = teamList }, Cmd.none )

        TeamListLoaded (Err err) ->
            ( { model | error = Just (toString err) }, Cmd.none )

        Navigate page ->
            model ! [ Navigation.newUrl (Route.routeToString page) ]

        DeleteTeamMember teamMemberEmail ->
            deleteRecord model nodeEnv apiKey { email = teamMemberEmail }

        DeleteTeamMemberResponse (Ok teamList) ->
            ( { model | teamList = teamList }, Cmd.none )

        DeleteTeamMemberResponse (Err error) ->
            ( { model | error = Just (toString error) }, Cmd.none )



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
            [ onClick (Navigate <| Route.TeamMemberCreate model.organizationKey)
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


deleteRecord : Model -> NodeEnv -> ApiKey -> UserEmailInput -> ( Model, Cmd Msg )
deleteRecord model nodeEnv apiKey userEmail =
    let
        cmd =
            Task.attempt TeamListLoaded (Reader.run removeTeamMember ( nodeEnv, apiKey, userEmail ))
    in
        ( model, cmd )
