module Page.Ticket.Edit exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Admin.Request.Ticket exposing (..)
import Request.Helpers exposing (NodeEnv, ApiKey)
import Admin.Data.Ticket exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)
import Field exposing (..)
import Helpers exposing (..)
import Field.ValidationResult exposing (..)
import GraphQL.Client.Http as GQLClient


-- MODEL


type alias Model =
    { error : Maybe String
    , success : Maybe String
    , note : String
    , message : String
    , ticketId : TicketId
    , status : TicketStatusEnum
    , statuses : List TicketStatus
    }


initModel : TicketId -> Model
initModel ticketId =
    { error = Nothing
    , success = Nothing
    , note = ""
    , message = ""
    , ticketId = ticketId
    , status = ""
    , statuses = []
    }


init : TicketId -> ( Model, Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error TicketEditData) )
init ticketId =
    ( initModel ticketId
    , requestTicketById ticketId
    )



-- UPDATE


type Msg
    = NoteInput String
    | UpdateTicket
    | UpdateTicketResponse (Result GQLClient.Error TicketInput)
    | TicketLoaded (Result GQLClient.Error TicketEditData)
    | UpdateTicketStatus Model String


update : Msg -> Model -> NodeEnv -> ApiKey -> ( Model, Cmd Msg )
update msg model nodeEnv organizationKey =
    case msg of
        NoteInput note ->
            ( { model | note = note }, Cmd.none )

        UpdateTicket ->
            let
                fields =
                    []

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
                    save model nodeEnv organizationKey
                else
                    ( { model | error = Just errors }, Cmd.none )

        UpdateTicketResponse (Ok ticket) ->
            ( { model
                | ticketId = ticket.id
                , status = ticket.status
                , success = Just "Ticket Updated Successfully..."
              }
            , Cmd.none
            )

        UpdateTicketResponse (Err error) ->
            ( { model | error = Just (toString error) }, Cmd.none )

        TicketLoaded (Ok ticket) ->
            ( { model
                | note = ticket.note
                , ticketId = ticket.id
                , message = ticket.message
                , statuses = ticket.statuses
                , status = ticket.status
              }
            , Cmd.none
            )

        TicketLoaded (Err err) ->
            ( { model | error = Just (toString err) }, Cmd.none )

        UpdateTicketStatus model status ->
            updateTicketStatus model { id = model.ticketId, status = status } nodeEnv organizationKey



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "row ticket-block" ]
        [ div
            [ class "col-md-8" ]
            [ Html.form []
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
                    [ label [] [ text <| "Message: " ++ model.message ]
                    ]
                , div []
                    [ label [] [ text "Note: " ]
                    , input
                        [ Html.Attributes.value <| model.note
                        , type_ "text"
                        , placeholder "add notes here..."
                        , onInput NoteInput
                        ]
                        []
                    ]
                , button [ type_ "submit", class "button primary" ] [ text "Update URL" ]
                ]
            ]
        , div [ class "col-sm" ]
            [ ticketStatusDropDown model ]
        ]


ticketInputs : TicketInput -> TicketInput
ticketInputs { id, status } =
    { status = status
    , id = id
    }


save : Model -> NodeEnv -> ApiKey -> ( Model, Cmd Msg )
save model nodeEnv organizationKey =
    --let
    --    cmd =
    --        Task.attempt UpdateTicketResponse (Reader.run (updateUrl) ( nodeEnv, organizationKey, urlInputs {  } ))
    --in
    ( model, Cmd.none )


updateTicketStatus : Model -> TicketInput -> NodeEnv -> ApiKey -> ( Model, Cmd Msg )
updateTicketStatus model ticketInput nodeEnv organizationKey =
    let
        cmd =
            Task.attempt UpdateTicketResponse (Reader.run (updateTicket) ( nodeEnv, organizationKey, ticketInputs (ticketInput) ))
    in
        ( model, cmd )


ticketStatusDropDown : Model -> Html Msg
ticketStatusDropDown model =
    let
        selectedCategory =
            List.filter (\status -> status.value == model.status)
                model.statuses
                |> List.map .key
                |> List.head
                |> Maybe.withDefault "Select Status"
    in
        div []
            [ div [ class "dropdown" ]
                [ a
                    [ class "btn btn-secondary dropdown-toggle"
                    , attribute "role" "button"
                    , attribute "data-toggle" "dropdown"
                    , attribute "aria-haspopup" "true"
                    , attribute "aria-expanded" "false"
                    ]
                    [ text selectedCategory ]
                , div
                    [ class "dropdown-menu", attribute "aria-labelledby" "dropdownMenuButton" ]
                    (List.map
                        (\status ->
                            a
                                [ onClick (UpdateTicketStatus model status.key)
                                , class "dropdown-item"
                                ]
                                [ text status.key ]
                        )
                        model.statuses
                    )
                ]
            ]
