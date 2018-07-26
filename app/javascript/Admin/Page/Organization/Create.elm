module Page.Organization.Create exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Admin.Data.Organization exposing (..)
import Request.Helpers exposing (NodeEnv)
import Admin.Request.Organization exposing (..)
import Reader exposing (Reader)
import Field exposing (..)
import Field.ValidationResult exposing (..)
import GraphQL.Client.Http as GQLClient
import Regex exposing (Regex)
import Task exposing (Task)
import Navigation
import Route

-- MODEL

type alias Model =
    { error: Maybe String
    , name : Field String String
    , email: Field String String
    , user_id: String
    }

initModel : String -> Model
initModel userId =
    { error = Nothing
    , name = Field (validateEmpty "Name") ""
    , email = Field (validateEmpty "Email" >> andThen validateEmail) ""
    , user_id = userId
    }

init: ( Model, Cmd Msg )
init =
    ( initModel "fe8ab352-be16-4e83-9d6f-d57393cc2c0f"
    , send LoadEmpty
    )

-- UPDATE

send : msg -> Cmd msg
send msg =
  Task.succeed msg
  |> Task.perform identity

type Msg
    = OrgNameInput String
    | OrgEmailInput String
    | SaveOrganization
    | SaveOrgResponse (Result GQLClient.Error OrganizationData)
    | LoadEmpty

update : Msg -> Model -> NodeEnv -> ( Model, Cmd Msg )
update msg model nodeEnv =
    case msg of
        LoadEmpty ->
            ( model, Cmd.none )
        OrgNameInput name ->
            ( { model | name = Field.update model.name name }, Cmd.none )
        OrgEmailInput email ->
            ( { model | email = Field.update model.email email }, Cmd.none )

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
                        |> String.join ", "
            in
                if isAllValid fields then
                    save model nodeEnv
                else
                    ( {model | error = Just "Please check your inputs" }, Cmd.none )
        SaveOrgResponse (Ok id) ->
            ({ model
            | name = Field.update model.name ""
            , email = Field.update model.email ""
            , error = Nothing
            }, Navigation.modifyUrl (Route.routeToString Route.Dashboard) )
        SaveOrgResponse (Err error) ->
            ( { model | error = Just (toString error) }, Cmd.none )

view : Model -> Html Msg
view model =
    div [ class "container"]
    [ Html.form [onSubmit SaveOrganization ]
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
            , button [ type_ "submit", class "button primary" ] [ text "Save URL" ]
        ]
    ]

orgInputs : Model -> OrganizationData
orgInputs { name, email, user_id } =
    { name = Field.value name
    , email = Field.value email
    , user_id = user_id
    }

save : Model -> NodeEnv -> (Model, Cmd Msg )
save model nodeEnv =
    let
        cmd =
            Task.attempt SaveOrgResponse ( Reader.run ( requestCreateOrganization (orgInputs model)) nodeEnv )
    in
        ( model, cmd )


validateEmail : String -> ValidationResult String String
validateEmail s =
    case (Regex.contains validEmail s) of
        True ->
            Passed s

        False ->
            Failed "Please enter a valid email"

validEmail : Regex
validEmail =
    Regex.regex "^[a-zA-Z0-9.!#$%&'*+\\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        |> Regex.caseInsensitive

validateEmpty : String -> String -> ValidationResult String String
validateEmpty n s =
    case s of
        "" ->
            Failed <| n ++ " cannot be empty"

        _ ->
            Passed s