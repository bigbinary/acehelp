module Page.Ticket.Edit exposing
    ( Model
    , Msg(..)
    , agentOption
    , agentsDropDown
    , assignTicketAgent
    , closeTicketButton
    , commentRows
    , defaultOption
    , deleteTicket
    , deleteTicketButton
    , init
    , initModel
    , noteRows
    , save
    , statusOption
    , ticketInputs
    , ticketNoteComment
    , ticketStatusDropDown
    , update
    , updateTicketStatus
    , view
    )

import Admin.Data.ReaderCmd exposing (..)
import Admin.Data.Ticket exposing (..)
import Admin.Request.Ticket exposing (..)
import GraphQL.Client.Http as GQLClient
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)



-- MODEL


type alias Model =
    { error : Maybe String
    , success : Maybe String
    , message : String
    , ticketId : TicketId
    , status : String
    , statuses : List TicketStatus
    , comments : List Comment
    , notes : List Note
    , comment : Comment
    , agents : List Agent
    , agent : Maybe Agent
    , note : Note
    }


initModel : TicketId -> Model
initModel ticketId =
    { error = Nothing
    , success = Nothing
    , note = Note ticketId ""
    , message = ""
    , ticketId = ticketId
    , status = ""
    , statuses = []
    , comments = []
    , notes = []
    , comment = Comment ticketId "" ""
    , agents = []
    , agent = Nothing
    }


init : TicketId -> ( Model, List (ReaderCmd Msg) )
init ticketId =
    ( initModel ticketId
    , [ Strict <| Reader.map (Task.attempt TicketLoaded) (requestTicketById ticketId)
      , Strict <| Reader.map (Task.attempt AgentsLoaded) requestAgents
      ]
    )



-- UPDATE


type Msg
    = NoteInput String
    | CommentInput String
    | UpdateTicket
    | DeleteTicket
    | UpdateTicketResponse (Result GQLClient.Error (Maybe Ticket))
    | DeleteTicketResponse (Result GQLClient.Error (Maybe Ticket))
    | TicketLoaded (Result GQLClient.Error (Maybe Ticket))
    | AgentsLoaded (Result GQLClient.Error (Maybe (List Agent)))
    | UpdateTicketStatus String
    | AssignTicketAgent String


update : Msg -> Model -> ( Model, List (ReaderCmd Msg) )
update msg model =
    case msg of
        NoteInput note ->
            ( { model | note = Note model.ticketId note }, [] )

        CommentInput comment ->
            ( { model | comment = Comment model.ticketId comment "" }, [] )

        UpdateTicket ->
            save model

        DeleteTicket ->
            deleteTicket model

        UpdateTicketResponse (Ok tkt) ->
            case tkt of
                Just ticket ->
                    ( { model
                        | ticketId = ticket.id
                        , status = ticket.status
                        , statuses = ticket.statuses
                        , message = ticket.message
                        , comment = Comment ticket.id "" ""
                        , note = Note ticket.id ""
                        , comments = ticket.comments
                        , notes = ticket.notes
                        , success = Just "Ticket Updated Successfully..."
                      }
                    , []
                    )

                Nothing ->
                    ( model, [] )

        UpdateTicketResponse (Err error) ->
            ( { model | error = Just "An error occured while updating the Ticket" }, [] )

        DeleteTicketResponse (Ok id) ->
            ( model, [] )

        DeleteTicketResponse (Err error) ->
            ( { model | error = Just "An error occured while deletin(Maybe g the )Ticket" }, [] )

        TicketLoaded (Ok tkt) ->
            case tkt of
                Just ticket ->
                    ( { model
                        | ticketId = ticket.id
                        , status = ticket.status
                        , statuses = ticket.statuses
                        , message = ticket.message
                        , comment = Comment ticket.id "" ""
                        , note = Note ticket.id ""
                        , comments = ticket.comments
                        , notes = ticket.notes
                        , success = Nothing
                      }
                    , []
                    )

                Nothing ->
                    ( model, [] )

        TicketLoaded (Err err) ->
            ( { model | error = Just "There was an error loading the Ticket" }, [] )

        UpdateTicketStatus status ->
            updateTicketStatus model { id = model.ticketId, status = status }

        AssignTicketAgent agent_id ->
            assignTicketAgent model { id = model.ticketId, agent_id = agent_id }

        AgentsLoaded (Ok agentList) ->
            case agentList of
                Just agents ->
                    ( { model
                        | agents = agents
                      }
                    , []
                    )

                Nothing ->
                    ( model, [] )

        AgentsLoaded (Err err) ->
            ( { model | error = Just "There was an error loading Agents" }, [] )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "row ticket-block" ]
        [ div
            [ class "col-md-8" ]
            [ div []
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
                , div []
                    [ Maybe.withDefault (text "") <|
                        Maybe.map
                            (\message ->
                                div
                                    [ class "alert alert-success alert-dismissible fade show"
                                    , attribute "role" "alert"
                                    ]
                                    [ text <| message
                                    ]
                            )
                            model.success
                    ]
                , div [ class "card" ]
                    [ h5 [] [ text "Message" ]
                    , p [ class "card-text" ] [ text model.message ]
                    ]
                , p [] []
                , ul [ class "nav nav-tabs" ]
                    [ li [ class "nav-item active" ]
                        [ a
                            [ class "nav-link active"
                            , attribute "data-toggle" "tab"
                            , href "#notes"
                            ]
                            [ text "Internal Note" ]
                        ]
                    , li [ class "nav-item" ]
                        [ a
                            [ class "nav-link"
                            , attribute "data-toggle" "tab"
                            , href "#comment"
                            ]
                            [ text "Reply to Customer" ]
                        ]
                    ]
                , div [ class "tab-content" ]
                    [ div [ class "tab-pane active form-group", id "notes" ]
                        [ h3 [] [ text "Notes: " ]
                        , div [ class "ticket-notes" ]
                            (List.map
                                (\note ->
                                    noteRows note
                                )
                                model.notes
                            )
                        , input
                            [ Html.Attributes.value <| model.note.details
                            , type_ "text"
                            , class "form-control"
                            , placeholder "add notes here..."
                            , onInput NoteInput
                            ]
                            []
                        ]
                    , div [ class "tab-pane fade form-group", id "comment" ]
                        [ h3 [] [ text "Comment: " ]
                        , input
                            [ Html.Attributes.value <| model.comment.info
                            , type_ "text"
                            , placeholder "add comments here..."
                            , class "form-control"
                            , onInput CommentInput
                            ]
                            []
                        , p [] []
                        , h5 [] [ text "Comment List: " ]
                        , div [ class "ticket-comments" ]
                            (List.map
                                (\comment ->
                                    commentRows comment
                                )
                                model.comments
                            )
                        ]
                    ]
                , p [] []
                , button [ type_ "submit", class "btn btn-primary", onClick UpdateTicket ]
                    [ text "Submit"
                    ]
                ]
            ]
        , div [ class "col-sm" ]
            [ ticketStatusDropDown model
            , agentsDropDown model
            , closeTicketButton model
            , deleteTicketButton model
            ]
        ]


ticketInputs : TicketInput -> TicketInput
ticketInputs { id, status } =
    { status = status
    , id = id
    }


ticketNoteComment : Model -> TicketNoteComment
ticketNoteComment model =
    { comment = model.comment.info
    , id = model.ticketId
    , note = model.note.details
    }


updateTicketStatus : Model -> TicketInput -> ( Model, List (ReaderCmd Msg) )
updateTicketStatus model ticketInput =
    let
        cmd =
            Strict <| Reader.map (Task.attempt UpdateTicketResponse) (updateTicket ticketInput)
    in
    ( model, [ cmd ] )


assignTicketAgent : Model -> TicketAgentInput -> ( Model, List (ReaderCmd Msg) )
assignTicketAgent model ticketAgentInput =
    let
        cmd =
            Strict <|
                Reader.map (Task.attempt UpdateTicketResponse)
                    (assignTicketToAgent
                        { id = ticketAgentInput.id
                        , agent_id = ticketAgentInput.agent_id
                        }
                    )
    in
    ( model, [ cmd ] )


deleteTicket : Model -> ( Model, List (ReaderCmd Msg) )
deleteTicket model =
    let
        cmd =
            Strict <| Reader.map (Task.attempt DeleteTicketResponse) (deleteTicketRequest model.ticketId)
    in
    ( model, [ cmd ] )


save : Model -> ( Model, List (ReaderCmd Msg) )
save model =
    let
        cmd =
            Strict <|
                Reader.map (Task.attempt UpdateTicketResponse)
                    (addNotesAndCommentToTicket
                        (ticketNoteComment model)
                    )
    in
    ( model, [ cmd ] )


ticketStatusDropDown : Model -> Html Msg
ticketStatusDropDown model =
    div []
        [ div [ class "status-selection" ]
            [ div []
                [ h2 [] [ text "SaveStatus Selector" ]
                , select [ onInput UpdateTicketStatus, class "custom-select custom-select-lg mb-3" ]
                    (List.map (statusOption model) model.statuses)
                ]
            ]
        ]


agentsDropDown : Model -> Html Msg
agentsDropDown model =
    div []
        [ div [ class "agent-selection" ]
            [ div []
                [ h2 [] [ text "Agent Selector" ]
                , select [ onInput AssignTicketAgent, class "custom-select custom-select-lg mb-3" ]
                    (List.map (agentOption model.agent) model.agents)
                ]
            ]
        ]


statusOption : Model -> TicketStatus -> Html Msg
statusOption model status =
    if status.value == model.status then
        option [ value status.value, selected True ] [ text status.key ]

    else
        option [ value status.value ] [ text status.key ]


agentOption currentAgent agent =
    case currentAgent of
        Nothing ->
            option [ value agent.id ] [ text agent.name ]

        Just selectedAgent ->
            if agent == selectedAgent then
                option [ value agent.id, selected True ] [ text agent.name ]

            else
                option [ value agent.id ] [ text agent.name ]


defaultOption _ =
    option [ disabled True, selected True ] [ text "Select Agent" ]


closeTicketButton : Model -> Html Msg
closeTicketButton model =
    div []
        [ button
            [ onClick (UpdateTicketStatus "closed")
            , class "btn btn-primary closeTicket"
            ]
            [ text "Close Ticket" ]
        ]


deleteTicketButton : Model -> Html Msg
deleteTicketButton model =
    div []
        [ p [] []
        , button
            [ onClick DeleteTicket
            , class "btn btn-primary deleteTicket"
            ]
            [ text "Delete Ticket" ]
        ]


commentRows : Comment -> Html Msg
commentRows comment =
    div
        [ class "comment-row" ]
        [ span [ class "row-id", id comment.ticket_id ] []
        , span [ class "row-name" ] [ text comment.info ]
        ]


noteRows : Note -> Html Msg
noteRows note =
    div
        [ class "note-row" ]
        [ span [ class "row-id", id note.ticket_id ] [ text "Note : " ]
        , span [ class "row-name" ] [ text note.details ]
        ]
