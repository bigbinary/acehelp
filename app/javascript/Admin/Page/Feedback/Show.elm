module Page.Feedback.Show exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Admin.Data.Feedback exposing (..)
import Admin.Request.Feedback exposing (..)
import Request.Helpers exposing (NodeEnv, ApiKey)
import Reader exposing (Reader)
import Task exposing (Task)
import GraphQL.Client.Http as GQLClient
import Admin.Data.ReaderCmd exposing (..)


-- Model


type alias Model =
    { name : String
    , message : String
    , id : FeedbackId
    , status : String
    , error : Maybe String
    , success : Maybe String
    }


initModel : FeedbackId -> Model
initModel feedbackId =
    { name = ""
    , message = ""
    , id = feedbackId
    , status = ""
    , error = Nothing
    , success = Nothing
    }


init : FeedbackId -> ( Model, List (ReaderCmd Msg) )
init feedbackId =
    ( initModel feedbackId
    , [ Strict <| Reader.map (Task.attempt FeedbackLoaded) (requestFeedbackById feedbackId) ]
    )



-- Update


type Msg
    = FeedbackLoaded (Result GQLClient.Error Feedback)
    | UpdateFeedabackStatus FeedbackId String
    | UpdateFeedbackResponse (Result GQLClient.Error Feedback)



-- TODO: Fetch categories to populate categories dropdown


update : Msg -> Model -> ( Model, List (ReaderCmd Msg) )
update msg model =
    case msg of
        FeedbackLoaded (Ok feedback) ->
            ( { model
                | name = feedback.name
                , message = feedback.message
                , id = feedback.id
                , status = feedback.status
              }
            , []
            )

        FeedbackLoaded (Err err) ->
            ( { model | error = Just "There was an error loading up the Feedback" }
            , []
            )

        UpdateFeedabackStatus feedbackId status ->
            updateFeedabackStatus model feedbackId status

        UpdateFeedbackResponse (Ok feedback) ->
            ( model, [] )

        UpdateFeedbackResponse (Err error) ->
            ( { model | error = Just "There was an error when updating the Feedback" }
            , []
            )



-- View


view : Model -> Html Msg
view model =
    div
        [ id model.id ]
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
        , div
            []
            [ text model.message ]
        , div
            []
            [ feedbackStatusButton model model.status ]
        ]


updateFeedabackStatus : Model -> FeedbackId -> String -> ( Model, List (ReaderCmd Msg) )
updateFeedabackStatus model feedbackId feedbackStatus =
    let
        cmd =
            Strict <| Reader.map (Task.attempt UpdateFeedbackResponse) (requestUpdateFeedbackStatus feedbackId feedbackStatus)
    in
        ( model, [ cmd ] )


feedbackStatusButton : Model -> String -> Html Msg
feedbackStatusButton model status =
    case status of
        "closed" ->
            Html.a
                [ onClick (UpdateFeedabackStatus model.id "open")
                , class "btn btn-primary"
                ]
                [ text <| "Open Feedback" ]

        _ ->
            Html.a
                [ onClick (UpdateFeedabackStatus model.id "closed")
                , class "btn btn-primary"
                ]
                [ text <| "Close Feedback" ]
