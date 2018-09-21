module Page.Feedback.List exposing (Model, Msg(..), init, initModel, requestFeedbacksList, row, update, view)

--import Http

import Admin.Data.Feedback exposing (..)
import Admin.Data.ReaderCmd exposing (..)
import Admin.Request.Feedback exposing (..)
import Admin.Request.Helper exposing (ApiKey)
import GraphQL.Client.Http as GQLClient
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Reader exposing (Reader)
import Route exposing (..)
import Task exposing (Task)



-- MODEL


type alias Model =
    { feedbackList : List Feedback
    , error : Maybe String
    }


initModel : Model
initModel =
    { feedbackList = []
    , error = Nothing
    }


init : ( Model, List (ReaderCmd Msg) )
init =
    ( initModel
    , [ Strict <| Reader.map (Task.attempt FeedbackListLoaded) (requestFeedbacks "open") ]
    )



-- UPDATE


type Msg
    = FeedbackListLoaded (Result GQLClient.Error (Maybe (List Feedback)))
    | FeedbackListReloaded FeedbackStatus


update : Msg -> Model -> ( Model, List (ReaderCmd Msg) )
update msg model =
    case msg of
        FeedbackListLoaded (Ok recvFeedbacks) ->
            case recvFeedbacks of
                Just feedbacks ->
                    ( { model | feedbackList = feedbacks }, [] )

                Nothing ->
                    ( model, [] )

        FeedbackListLoaded (Err err) ->
            ( { model | error = Just "Could not fetch Feedback list" }, [] )

        FeedbackListReloaded status ->
            requestFeedbacksList model status



-- VIEW


view : ApiKey -> Model -> Html Msg
view orgKey model =
    div
        [ id "feedback_list" ]
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
        , ul [ class "nav nav-tabs" ]
            [ li [ class "nav-item active" ]
                [ a
                    [ class "nav-link active"
                    , attribute "data-toggle" "tab"
                    , href "#open-feedbacks"
                    , onClick (FeedbackListReloaded "open")
                    ]
                    [ text "Open Feedback" ]
                ]
            , li [ class "nav-item" ]
                [ a
                    [ class "nav-link"
                    , attribute "data-toggle" "tab"
                    , href "#closed-feedbacks"
                    , onClick (FeedbackListReloaded "closed")
                    ]
                    [ text "Closed Feedback" ]
                ]
            ]
        , div [ class "tab-content" ]
            [ div [ class "tab-pane active form-group", id "open-feedbacks" ]
                [ div [ id "content-wrapper" ]
                    (List.map
                        (\feedback ->
                            row orgKey model feedback
                        )
                        model.feedbackList
                    )
                ]
            , div [ class "tab-pane form-group", id "closed-feedbacks" ]
                [ div [ id "content-wrapper" ]
                    (List.map
                        (\feedback ->
                            row orgKey model feedback
                        )
                        model.feedbackList
                    )
                ]
            ]
        ]


row : ApiKey -> Model -> Feedback -> Html Msg
row orgKey model feedback =
    div
        [ class "feedback-row" ]
        [ span [ class "row-id" ]
            [ a [ href <| routeToString <| FeedbackShow feedback.id orgKey ]
                [ text feedback.id ]
            ]
        , span [ class "row-name" ] [ text feedback.name ]
        , span [ class "row-message" ] [ text feedback.message ]
        ]


requestFeedbacksList : Model -> FeedbackStatus -> ( Model, List (ReaderCmd Msg) )
requestFeedbacksList model status =
    let
        cmd =
            Strict <| Reader.map (Task.attempt FeedbackListLoaded) (requestFeedbacks status)
    in
    ( model, [ cmd ] )
