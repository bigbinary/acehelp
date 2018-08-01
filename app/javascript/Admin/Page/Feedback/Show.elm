module Page.Feedback.Show exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Admin.Data.Feedback exposing (..)
import Admin.Request.Feedback exposing (..)
import Request.Helpers exposing (NodeEnv, ApiKey)
import Reader exposing (Reader)
import Task exposing (Task)
import Helpers exposing (..)
import GraphQL.Client.Http as GQLClient


-- Model


type alias Model =
    { name : String
    , message : String
    , id : FeedbackId
    , error : Maybe String
    , success : Maybe String
    }


initModel : FeedbackId -> Model
initModel feedbackId =
    { name = ""
    , message = ""
    , id = feedbackId
    , error = Nothing
    , success = Nothing
    }


init : FeedbackId -> ( Model, Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error Feedback) )
init feedbackId =
    ( initModel feedbackId
    , requestFeedbackById feedbackId
    )



-- Update


type Msg
    = FeedbackLoaded (Result GQLClient.Error Feedback)
    | UpdateFeedabackStatus FeedbackId
    | UpdateFeedbackResponse (Result GQLClient.Error Feedback)



-- TODO: Fetch categories to populate categories dropdown


update : Msg -> Model -> NodeEnv -> ApiKey -> ( Model, Cmd Msg )
update msg model nodeEnv organizationKey =
    case msg of
        FeedbackLoaded (Ok feedback) ->
            ( { model
                | name = feedback.name
                , message = feedback.message
                , id = feedback.id
              }
            , Cmd.none
            )

        FeedbackLoaded (Err err) ->
            ( { model | error = Just "There was an error loading up the feedback" }
            , Cmd.none
            )

        UpdateFeedabackStatus feedbackId ->
            updateFeedabackStatus model nodeEnv organizationKey feedbackId

        UpdateFeedbackResponse (Ok feedback) ->
            ( { model
                | name = feedback.name
                , message = feedback.message
                , id = feedback.id
                , success = Just "Feedback Updated Successfully."
              }
            , Cmd.none
            )

        UpdateFeedbackResponse (Err error) ->
            ( { model | error = Just (toString error) }
            , Cmd.none
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
            [ Html.a
                [ onClick (UpdateFeedabackStatus model.id)
                , class "button primary"
                ]
                [ text "Close Feedback" ]
            ]
        ]


updateFeedabackStatus : Model -> NodeEnv -> ApiKey -> FeedbackId -> ( Model, Cmd Msg )
updateFeedabackStatus model nodeEnv apiKey feedbackId =
    let
        cmd =
            Task.attempt UpdateFeedbackResponse (Reader.run (requestUpdateFeedbackStatus feedbackId) ( nodeEnv, apiKey ))
    in
        ( model, cmd )
