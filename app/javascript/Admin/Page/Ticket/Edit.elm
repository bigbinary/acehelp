module Page.Ticket.Edit exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Admin.Request.Ticket exposing (..)
import Request.Helpers exposing (NodeEnv, ApiKey)
import Admin.Data.Common exposing (..)
import Admin.Data.Ticket exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)
import Helpers exposing (..)
import GraphQL.Client.Http as GQLClient


-- MODEL


type alias Model =
    { error : Maybe String
    , success : Maybe String
    , note : String
    , message : String
    , ticketId : TicketId
    , status : String
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


init : TicketId -> ( Model, Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error Ticket) )
init ticketId =
    ( initModel ticketId
    , requestTicketById ticketId
    )



-- UPDATE


type Msg
    = NoteInput String
    | UpdateTicket
    | UpdateTicketResponse (Result GQLClient.Error Ticket)
    | TicketLoaded (Result GQLClient.Error Ticket)
    | UpdateTicketStatus String


update : Msg -> Model -> NodeEnv -> ApiKey -> ( Model, Cmd Msg )
update msg model nodeEnv organizationKey =
    case msg of
        NoteInput note ->
            ( { model | note = note }, Cmd.none )

        UpdateTicket ->
            ( model, Cmd.none )

        UpdateTicketResponse (Ok ticket) ->
            ( { model
                | ticketId = ticket.id
                , status = ticket.status
                , statuses = ticket.statuses
                , message = ticket.message
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

        UpdateTicketStatus status ->
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
    div []
        [ div [ class "status-selection" ]
            [ div []
                [ h2 [] [ text "Status Selector" ]
                , select [ onInput UpdateTicketStatus ]
                    (List.map (statusOption model) model.statuses)
                ]
            ]
        ]


statusOption model status =
    if status.value == model.status then
        option [ value (status.value), selected True ] [ text (status.key) ]
    else
        option [ value (status.value) ] [ text (status.key) ]
