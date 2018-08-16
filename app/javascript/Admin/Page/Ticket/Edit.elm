module Page.Ticket.Edit exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Admin.Request.Ticket exposing (..)
import Admin.Data.Ticket exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)
import GraphQL.Client.Http as GQLClient
import Admin.Data.ReaderCmd exposing (..)


-- MODEL


type alias Model =
    { error : Maybe String
    , success : Maybe String
    , note : String
    , message : String
    , ticketId : TicketId
    , status : String
    , statuses : List TicketStatus
    , comments : List Comment
    , comment : Comment
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
    , comments = []
    , comment = Comment ticketId "" ""
    }


init : TicketId -> ( Model, List (ReaderCmd Msg) )
init ticketId =
    ( initModel ticketId
    , [ Strict <| Reader.map (Task.attempt TicketLoaded) (requestTicketById ticketId) ]
    )



-- UPDATE


type Msg
    = NoteInput String
    | UpdateTicket
    | DeleteTicket
    | UpdateTicketResponse (Result GQLClient.Error Ticket)
    | DeleteTicketResponse (Result GQLClient.Error Ticket)
    | TicketLoaded (Result GQLClient.Error Ticket)
    | UpdateTicketStatus String


update : Msg -> Model -> ( Model, List (ReaderCmd Msg) )
update msg model =
    case msg of
        NoteInput note ->
            ( { model | note = note }, [] )

        UpdateTicket ->
            ( model, [] )

        DeleteTicket ->
            deleteTicket model

        UpdateTicketResponse (Ok ticket) ->
            ( { model
                | ticketId = ticket.id
                , status = ticket.status
                , statuses = ticket.statuses
                , message = ticket.message
                , success = Just "Ticket Updated Successfully..."
              }
            , []
            )

        UpdateTicketResponse (Err error) ->
            ( { model | error = Just (toString error) }, [] )

        DeleteTicketResponse (Ok id) ->
            ( model, [] )

        DeleteTicketResponse (Err error) ->
            ( { model | error = Just (toString error) }, [] )

        TicketLoaded (Ok ticket) ->
            ( { model
                | note = ticket.note
                , ticketId = ticket.id
                , message = ticket.message
                , statuses = ticket.statuses
                , status = ticket.status
              }
            , []
            )

        TicketLoaded (Err err) ->
            ( { model | error = Just (toString err) }, [] )

        UpdateTicketStatus status ->
            updateTicketStatus model { id = model.ticketId, status = status }



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
                , ul [ class "nav nav-tabs" ]
                    [ li [ class "active" ]
                        [ a [ attribute "data-toggle" "tab", href "#notes" ]
                            [ text "Internal Note" ]
                        ]
                    , li []
                        [ a [ attribute "data-toggle" "tab", href "#comment" ]
                            [ text "Reply to Customer" ]
                        ]
                    ]
                , div [ class "tab-content" ]
                    [ div [ class "tab-pane fade in active", id "notes" ]
                        [ h3 [] [ text "Notes: " ]
                        , input
                            [ Html.Attributes.value <| model.note
                            , type_ "text"
                            , placeholder "add notes here..."
                            , onInput NoteInput
                            ]
                            []
                        ]
                    , div [ class "tab-pane fade", id "comment" ]
                        [ h3 [] [ text "Comment: " ]
                        , div [ class "ticket-comments" ]
                            (List.map
                                (\comment ->
                                    commentRows comment
                                )
                                model.comments
                            )
                        , input
                            [ Html.Attributes.value <| model.note
                            , type_ "text"
                            , placeholder "add comments here..."
                            , onInput NoteInput
                            ]
                            []
                        ]
                    ]
                , button [ type_ "submit", class "button primary" ] [ text "Update URL" ]
                ]
            ]
        , div [ class "col-sm" ]
            [ ticketStatusDropDown model
            , closeTicketButton model
            , deleteTicketButton model
            ]
        ]


updateTicketStatus : Model -> TicketInput -> ( Model, List (ReaderCmd Msg) )
updateTicketStatus model ticketInput =
    let
        cmd =
            Strict <| Reader.map (Task.attempt UpdateTicketResponse) (updateTicket ticketInput)
    in
        ( model, [ cmd ] )


deleteTicket : Model -> ( Model, List (ReaderCmd Msg) )
deleteTicket model =
    let
        cmd =
            Strict <| Reader.map (Task.attempt DeleteTicketResponse) (deleteTicketRequest model.ticketId)
    in
        ( model, [ cmd ] )


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


statusOption : Model -> TicketStatus -> Html Msg
statusOption model status =
    if status.value == model.status then
        option [ value (status.value), selected True ] [ text (status.key) ]
    else
        option [ value (status.value) ] [ text (status.key) ]


closeTicketButton : Model -> Html Msg
closeTicketButton model =
    div []
        [ button
            [ onClick (UpdateTicketStatus "closed")
            , class "button primary closeTicket"
            ]
            [ text "Close Ticket" ]
        ]


deleteTicketButton : Model -> Html Msg
deleteTicketButton model =
    div []
        [ button
            [ onClick (DeleteTicket)
            , class "button primary deleteTicket"
            ]
            [ text "Delete Ticket" ]
        ]


commentRows : Comment -> Html Msg
commentRows comment =
    div
        [ class "comment-row" ]
        [ span [ class "row-id" ] [ text comment.ticket_id ]
        , span [ class "row-name" ] [ text comment.info ]
        ]
