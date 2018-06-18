module Main exposing (..)

import Html exposing (Html, div, text, button)
import Navigation exposing (..)
import Page.Organization.Show as OrganizationShow


-- MODEL


type alias Flags =
    { node_env : String
    }


type alias Model =
    { currentPage : Page
    , organizationShow : OrganizationShow.Model
    , location : Location
    }


type Page
    = OrganizationShow
    | NotFound


init : Flags -> Location -> ( Model, Cmd Msg )
init flags location =
    let
        page =
            retrivePage location.pathname

        ( organizationShowModel, organizationShowCmds ) =
            OrganizationShow.init


        initModel =
            { currentPage = page
            , organizationShow = organizationShowModel
            , location = location
            }

        cmds =
            Cmd.batch
                [ Cmd.map OrganizationShowMsg organizationShowCmds
                ]
    in
        ( initModel, cmds )



-- MSG


type Msg
    = Navigate Page
    | ChangePage Page
    | OrganizationShowMsg OrganizationShow.Msg



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Navigate page ->
            ( model, newUrl <| convertPageToHash page )

        ChangePage page ->
            ( { model | currentPage = page }, Cmd.none )

        OrganizationShowMsg osMsg ->
            let
                ( organizationShowModel, organizationShowCmds ) =
                    OrganizationShow.update osMsg model.organizationShow
            in
                ( { model | organizationShow = organizationShowModel }
                , Cmd.map OrganizationShowMsg organizationShowCmds
                )


convertPageToHash : Page -> String
convertPageToHash page =
    case page of
        OrganizationShow ->
            "/admin/organization/2"

        NotFound ->
            "/404"


urlLocationToMsg : Location -> Msg
urlLocationToMsg location =
    location.pathname
        |> retrivePage
        |> ChangePage


retrivePage : String -> Page
retrivePage pathname =
    case pathname of
        "/admin/organization/1" ->
            OrganizationShow

        _ ->
            NotFound



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    let
        page =
            case model.currentPage of
                OrganizationShow ->
                    Html.map OrganizationShowMsg
                        (OrganizationShow.view model.organizationShow)

                _ ->
                    div [] [ text "" ]
    in
        div []
            [ page
            ]


-- MAIN


main : Program Flags Model Msg
main =
    Navigation.programWithFlags urlLocationToMsg
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
