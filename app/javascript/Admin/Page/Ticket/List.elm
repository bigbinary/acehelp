module Page.Ticket.List exposing (..)

--import Http

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Admin.Views.Common exposing (renderError)
import Admin.Request.Ticket exposing (..)
import Admin.Data.Ticket exposing (..)
import Task exposing (Task)
import Reader exposing (Reader)
import GraphQL.Client.Http as GQLClient
import Admin.Data.ReaderCmd exposing (..)


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


init : ( Model, List (ReaderCmd Msg) )
init =
    ( initModel, [ Strict <| Reader.map (Task.attempt TicketLoaded) requestTickets ] )



-- UPDATE


type Msg
    = TicketLoaded (Result GQLClient.Error (Maybe (List Ticket)))
    | OnEditTicketClick TicketId


update : Msg -> Model -> ( Model, List (ReaderCmd Msg) )
update msg model =
    case msg of
        TicketLoaded (Ok ticketList) ->
            case ticketList of
                Just tickets ->
                    ( { model | ticketList = tickets }, [] )

                Nothing ->
                    ( model, [] )

        TicketLoaded (Err err) ->
            ( { model | error = Just (toString err) }, [] )

        OnEditTicketClick _ ->
            -- NOTE: Handled in Main
            ( model, [] )



-- VIEW


view : Model -> Html Msg
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
                    rows model ticket
                )
                model.ticketList
            )
        ]


rows : Model -> Ticket -> Html Msg
rows model ticket =
    div
        [ class "listingRow" ]
        [ span [ class "row-id" ] [ text ticket.id ]
        , span [ class "row-name" ] [ text ticket.name ]
        , span [ class "row-email" ] [ text ticket.email ]
        , span [ class "row-message" ] [ text ticket.message ]
        , span [ onClick <| OnEditTicketClick ticket.id ] [ text " | Edit Ticket" ]
        ]
