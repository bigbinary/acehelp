module Page.Ticket.List exposing (..)

--import Http

import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Common.View exposing (renderError)
import Admin.Request.Ticket exposing (..)
import Request.Helpers exposing (NodeEnv, ApiKey)
import Admin.Data.Ticket exposing (..)
import Task exposing (Task)
import Reader exposing (Reader)
import GraphQL.Client.Http as GQLClient


-- MODEL


type alias Model =
    { ticketList : List Ticket
    , error : Maybe String
    }


initModel : Model
initModel =
    { ticketList = []
    , error = Nothing
    }


init : String -> String -> ( Model, Cmd Msg )
init env key =
    ( initModel, (fetchTicketList env key) )



-- UPDATE


type Msg
    = TicketLoaded (Result GQLClient.Error (List Ticket))


update : Msg -> Model -> ApiKey -> NodeEnv -> ( Model, Cmd Msg )
update msg model apiKey nodeEnv =
    case msg of
        TicketLoaded (Ok tickets) ->
            ( { model | ticketList = tickets }, Cmd.none )

        TicketLoaded (Err err) ->
            ( { model | error = Just (toString err) }, Cmd.none )



-- VIEW


view : Model -> Html msg
view model =
    div
        [ id "ticket_list"
        ]
        [ div
            []
            [ text (renderError model.error) ]
        , div
            [ id "content-wrapper" ]
            (List.map
                (\ticket ->
                    rows ticket
                )
                model.ticketList
            )
        ]


rows : Ticket -> Html msg
rows ticket =
    div
        [ class "ticket-row" ]
        [ span [ class "row-id" ] [ text ticket.id ]
        , span [ class "row-name" ] [ text ticket.name ]
        , span [ class "row-email" ] [ text ticket.email ]
        , span [ class "row-message" ] [ text ticket.message ]
        ]


fetchTicketList : String -> String -> Cmd Msg
fetchTicketList nodeEnv apiKey =
    Task.attempt TicketLoaded (Reader.run (requestTickets) ( nodeEnv, apiKey ))
