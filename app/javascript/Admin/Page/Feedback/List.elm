module Page.Feedback.List exposing (..)

--import Http

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Request.Helpers exposing (NodeEnv, ApiKey)
import Navigation exposing (..)
import Route
import Admin.Request.Feedback exposing (..)
import Admin.Data.Feedback exposing (..)
import Task exposing (Task)
import Reader exposing (Reader)
import GraphQL.Client.Http as GQLClient


-- MODEL


type alias Model =
    { feedbackList : List Feedback
    , organizationKey : String
    , error : Maybe String
    }


initModel : ApiKey -> Model
initModel organizationKey =
    { feedbackList = []
    , organizationKey = organizationKey
    , error = Nothing
    }


init : ApiKey -> ( Model, Reader ( NodeEnv, ApiKey, FeedbackStatus ) (Task GQLClient.Error (List Feedback)) )
init organizationKey =
    ( initModel organizationKey
    , requestFeedbacks
    )



-- UPDATE


type Msg
    = FeedbackListLoaded (Result GQLClient.Error (List Feedback))
    | FeedbackListReloaded FeedbackStatus
    | Navigate Route.Route


update : Msg -> Model -> ApiKey -> NodeEnv -> ( Model, Cmd Msg )
update msg model apiKey nodeEnv =
    case msg of
        FeedbackListLoaded (Ok feedbacks) ->
            ( { model | feedbackList = feedbacks }, Cmd.none )

        FeedbackListLoaded (Err err) ->
            ( { model | error = Just (toString err) }, Cmd.none )

        FeedbackListReloaded status ->
            requestFeedbacksList model apiKey nodeEnv status

        Navigate page ->
            model ! [ Navigation.newUrl (Route.routeToString page) ]



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
        , div
            [ class "buttonDiv" ]
            [ Html.a
                [ onClick (FeedbackListReloaded "closed")
                , class "button primary"
                ]
                [ text "Closed Feedback" ]
            ]
        , div
            [ class "buttonDiv" ]
            [ Html.a
                [ onClick (FeedbackListReloaded "open")
                , class "button primary"
                ]
                [ text "Open Feedback" ]
            ]
        , div []
            (List.map
                (\feedback ->
                    row model feedback
                )
                model.feedbackList
            )
        ]


row : Model -> Feedback -> Html Msg
row model feedback =
    div [ id feedback.id ]
        [ div
            [ onClick <| Navigate <| Route.FeedbackShow model.organizationKey feedback.id ]
            [ text feedback.name ]
        , div
            []
            [ text feedback.message ]
        , div
            []
            [ text feedback.status ]
        , hr [] []
        ]


requestFeedbacksList : Model -> ApiKey -> NodeEnv -> FeedbackStatus -> ( Model, Cmd Msg )
requestFeedbacksList model apiKey nodeEnv status =
    let
        cmd =
            Task.attempt FeedbackListLoaded (Reader.run (requestFeedbacks) ( nodeEnv, apiKey, status ))
    in
        ( model, cmd )
