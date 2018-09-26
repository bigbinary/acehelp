module Page.Ticket.List exposing (Model, Msg(..), init, initModel, rows, update, view)

--import Http

import Admin.Data.ReaderCmd exposing (..)
import Admin.Data.Ticket exposing (..)
import Admin.Request.Helper exposing (ApiKey)
import Admin.Request.Ticket exposing (..)
import Admin.Views.Common exposing (renderError)
import GraphQL.Client.Http as GQLClient
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Reader exposing (Reader)
import Route exposing (..)
import Task exposing (Task)



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
            ( { model | error = Just "There was an error loading tickets" }, [] )



-- VIEW


view : ApiKey -> Model -> Html Msg
view orgKey model =
    let
        tableHeading =
            thead
                []
                [ tr
                    []
                    [ th [ scope "col" ] [ text "ID" ]
                    , th [ scope "col" ] [ text "Name" ]
                    , th [ scope "col" ] [ text "Email" ]
                    , th [ scope "col" ] [ text "Message" ]
                    , th [] []
                    ]
                ]

        tableBody =
            tbody []
                (List.map
                    (\ticket ->
                        rows orgKey model ticket
                    )
                    model.ticketList
                )
    in
    div
        [ id "ticket_list" ]
        [ div [] [ text (renderError model.error) ]
        , table [ class "table table-hover" ] [ tableHeading, tableBody ]
        ]


rows : ApiKey -> Model -> Ticket -> Html Msg
rows orgKey model ticket =
    tr
        []
        [ td [ class "row-id" ] [ text ticket.id ]
        , td [ class "row-name" ] [ text ticket.name ]
        , td [ class "row-email" ] [ text ticket.email ]
        , td [ class "row-message" ] [ text ticket.message ]
        , td
            []
            [ a
                [ class "btn btn-primary"
                , href <| routeToString <| TicketEdit orgKey ticket.id
                ]
                [ text "View" ]
            ]
        ]
