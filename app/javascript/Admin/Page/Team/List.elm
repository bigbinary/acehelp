module Page.Team.List exposing (..)

--import Http

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Navigation exposing (..)
import Route
import Request.Helpers exposing (NodeEnv, ApiKey)
import Admin.Request.Team exposing (..)
import Admin.Data.Team exposing (..)
import Task exposing (Task)
import Reader exposing (Reader)
import GraphQL.Client.Http as GQLClient


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


update : Msg -> Model -> ApiKey -> NodeEnv -> ( Model, Cmd Msg )
update msg model apiKey nodeEnv =
    case msg of
        TeamListLoaded (Ok teamList) ->
            ( { model | teamList = teamList }, Cmd.none )

        TeamListLoaded (Err err) ->
            ( { model | error = Just (toString err) }, Cmd.none )

        Navigate page ->
            model ! [ Navigation.newUrl (Route.routeToString page) ]



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
        , div
            []
            [ Html.a
                [ onClick (Navigate <| Route.TeamMemberCreate model.organizationKey)
                , class "button primary"
                ]
                [ text " + Add Team Member " ]
            ]
        , div []
            (List.map
                (\teamMember ->
                    row teamMember
                )
                model.teamList
            )
        ]


row : Team -> Html Msg
row teamMember =
    div [ id teamMember.id ]
        [ div
            []
            [ text <| (teamMember.name ++ " | " ++ teamMember.email) ]
        , hr [] []
        ]
