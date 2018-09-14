module Page.Organization.Create exposing (Model, Msg(..), init, initModel, orgInputs, save, update, view)

import Admin.Data.Organization exposing (..)
import Admin.Data.ReaderCmd exposing (..)
import Admin.Request.Organization exposing (..)
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
    , name : Field String String
    , email : Field String String
    , user_id : String
    }


initModel : String -> Model
initModel userId =
    { errors = []
    , name = Field (validateEmpty "Name") ""
    , email = Field (validateEmpty "Email" >> andThen validateEmail) ""
    , user_id = userId
    }


init : String -> ( Model, List (ReaderCmd Msg) )
init userId =
    ( initModel userId
    , []
    )



-- UPDATE


type Msg
    = OrgNameInput String
    | OrgEmailInput String
    | SaveOrganization
    | SaveOrgResponse (Result GQLClient.Error OrganizationWithError)


update : Msg -> Model -> ( Model, List (ReaderCmd Msg) )
update msg model =
    case msg of
        OrgNameInput name ->
            ( { model | name = Field.update model.name name }, [] )

        OrgEmailInput email ->
            ( { model | email = Field.update model.email email }, [] )

        SaveOrganization ->
            let
                fields =
                    [ model.name, model.email ]

                errors =
                    validateAll fields
                        |> filterFailures
                        |> List.map
                            (\result ->
                                case result of
                                    Failed err ->
                                        err

                                    Passed okay ->
                                        "Unknown Error"
                            )
            in
                if isAllValid fields then
                    save model
                else
                    ( { model | errors = errors }, [] )

        SaveOrgResponse (Ok org) ->
            ( model, [] )

        SaveOrgResponse (Err error) ->
            ( { model | errors = [ "There was an error while saving organization details" ] }, [] )


renderErrors : List String -> Html Msg
renderErrors errors =
    case errors of
        [] ->
            text ""

        _ ->
            div [ class "alert alert-danger alert-dismissible fade show", attribute "role" "alert" ]
                [ text <| (++) "Error: " <| String.join ", " errors ]


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ div []
            [ renderErrors
                model.errors
            ]
        , div []
            [ label [] [ text "Name: " ]
            , input
                [ type_ "text"
                , placeholder "Organization Name..."
                , onInput OrgNameInput
                ]
                []
            ]
        , div []
            [ label [] [ text "Email: " ]
            , input
                [ type_ "email"
                , placeholder "Organization Email..."
                , onInput OrgEmailInput
                ]
                []
            ]
        , button [ onClick SaveOrganization, type_ "button", class "btn btn-primary" ] [ text "Save Organization" ]
        ]


orgInputs : Model -> OrganizationData
orgInputs { name, email, user_id } =
    { name = Field.value name
    , email = Field.value email
    , userId = user_id
    }


save : Model -> ( Model, List (ReaderCmd Msg) )
save model =
    let
        cmd =
            Open <| Reader.map (Task.attempt SaveOrgResponse) (requestCreateOrganization (orgInputs model))
    in
    ( model, [ cmd ] )
