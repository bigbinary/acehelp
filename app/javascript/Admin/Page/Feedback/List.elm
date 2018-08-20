module Page.Feedback.List exposing (..)

--import Http

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Admin.Request.Feedback exposing (..)
import Admin.Data.Feedback exposing (..)
import Task exposing (Task)
import Reader exposing (Reader)
import GraphQL.Client.Http as GQLClient
import Admin.Data.ReaderCmd exposing (..)


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
    = FeedbackListLoaded (Result GQLClient.Error (List Feedback))
    | FeedbackListReloaded FeedbackStatus
    | OnFeedbackClick FeedbackId


update : Msg -> Model -> ( Model, List (ReaderCmd Msg) )
update msg model =
    case msg of
        FeedbackListLoaded (Ok feedbacks) ->
            ( { model | feedbackList = feedbacks }, [] )

        FeedbackListLoaded (Err err) ->
            ( { model | error = Just (toString err) }, [] )

        FeedbackListReloaded status ->
            requestFeedbacksList model status

        OnFeedbackClick feedbackId ->
            -- NOTE: Handled in Main
            ( model, [] )



-- VIEW


view : Model -> Html Msg
view model =
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
                [ h3 [] [ text "Open Feedbacks: " ]
                , div [ id "content-wrapper" ]
                    (List.map
                        (\feedback ->
                            row model feedback
                        )
                        model.feedbackList
                    )
                ]
            , div [ class "tab-pane form-group", id "closed-feedbacks" ]
                [ h3 [] [ text "Closed Feedbacks: " ]
                , div [ id "content-wrapper" ]
                    (List.map
                        (\feedback ->
                            row model feedback
                        )
                        model.feedbackList
                    )
                ]
            ]
        ]


row : Model -> Feedback -> Html Msg
row model feedback =
    div
        [ class "feedback-row" ]
        [ span [ class "row-id", onClick <| OnFeedbackClick feedback.id ] [ text feedback.id ]
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
