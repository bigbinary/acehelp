module Page.Ticket.List exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Data.CommonData exposing (..)
import Page.Common.View exposing (renderError)


--import GraphQL.Client.Http as GQLClient
-- MODEL


type alias Ticket =
    { id : String
    , name : String
    }


type alias Model =
    { ticketList : List Ticket
    , error : Error
    }


initModel : Model
initModel =
    { ticketList = []
    , error = Nothing
    }


init : String -> String -> Model
init env organizationKey =
    ( initModel, (fetchUrlList env organizationKey) )



-- UPDATE


type Msg
    = TicketLoaded (List Ticket)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TicketLoaded tickets ->
            ( { model | ticketList = tickets }, Cmd.none )



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
            []
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
        []
        [ text ticket.name
        ]


fetchUrlList : String -> String -> Cmd Msg
fetchUrlList env key =
    Http.send TicketLoaded (requestUrls env key)
