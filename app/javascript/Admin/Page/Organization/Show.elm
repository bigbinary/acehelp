module Page.Organization.Show exposing (..)

import Http
import Html exposing (..)
import Html.Attributes exposing (..)
import Request.OrganizationRequest exposing (..)


--import Html.Events exposing (..)

import Data.OrganizationData exposing (..)


-- Model


type alias Model =
    { organization : OrganizationResponse
    , error : Maybe String
    }


initModel : Model
initModel =
    { organization = { organization = Organization 1 "Google" }
    , error = Nothing
    }


init : ( Model, Cmd Msg )
init =
    ( initModel, fetchOrganization )



-- Update


type Msg
    = FetchOrganization
    | OrganizationLoaded (Result Http.Error OrganizationResponse)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OrganizationLoaded (Ok organization) ->
            ( { model | organization = organization }, Cmd.none )

        OrganizationLoaded (Err err) ->
            ( { model | error = Just (toString err) }, Cmd.none )

        _ ->
            ( model, Cmd.none )



-- View


view : Model -> Html msg
view model =
    div [ id "content-wrapper" ]
        [ h1 [] [ text model.organization.organization.name ]
        ]

fetchOrganization : Cmd Msg
fetchOrganization =
    let
        request =
            requestOrganization "dev" "3c60b69a34f8cdfc76a0"

        cmd =
            Http.send OrganizationLoaded request
    in
        cmd
