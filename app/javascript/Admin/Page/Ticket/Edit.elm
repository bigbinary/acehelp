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
    }


initModel : TicketId -> Model
initModel ticketId =
    { error = Nothing
    , success = Nothing
    , note = ""
    , message = ""
    , ticketId = ticketId
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
    | UpdateTicketResponse (Result GQLClient.Error TicketEditData)
    | TicketLoaded (Result GQLClient.Error TicketEditData)


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
                | note = ticket.note
                , success = Just "Ticket Updated Successfully."
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
              }
            , Cmd.none
            )

        TicketLoaded (Err err) ->
            ( { model | error = Just (toString err) }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container" ]
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
                [ label [] [ text "Note: " ]
                , input
                    [ Html.Attributes.value <| model.note
                    , type_ "text"
                    , placeholder "add notes here..."
                    , onInput NoteInput
                    ]
                    []
                ]
            , div []
                [ label [] [ text model.message ]
                ]
            , button [ type_ "submit", class "button primary" ] [ text "Update URL" ]
            ]
        ]



--urlInputs : Model -> UrlData
--urlInputs { url, urlId } =
--    { url = Field.value url
--    , id = urlId
--    }


save : Model -> NodeEnv -> ApiKey -> ( Model, Cmd Msg )
save model nodeEnv organizationKey =
    --let
    --    cmd =
    --        Task.attempt UpdateTicketResponse (Reader.run (updateUrl) ( nodeEnv, organizationKey, urlInputs model ))
    --in
    ( model, Cmd.none )
