module Page.Feedback.List exposing (..)

--import Http

import Html exposing (..)
import Html.Attributes exposing (..)
import Request.Helpers exposing (NodeEnv, ApiKey)
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


init : ApiKey -> ( Model, Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error (List Feedback)) )
init organizationKey =
    ( initModel organizationKey
    , requestFeedbacks
    )



-- UPDATE


type Msg
    = FeedbackListLoaded (Result GQLClient.Error (List Feedback))


update : Msg -> Model -> ApiKey -> NodeEnv -> ( Model, Cmd Msg )
update msg model apiKey nodeEnv =
    case msg of
        FeedbackListLoaded (Ok feedbacks) ->
            ( { model | feedbackList = feedbacks }, Cmd.none )

        FeedbackListLoaded (Err err) ->
            ( { model | error = Just (toString err) }, Cmd.none )



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
        , div []
            (List.map
                (\feedback ->
                    row feedback
                )
                model.feedbackList
            )
        ]


row : Feedback -> Html Msg
row feedback =
    div [ id feedback.id ]
        [ div
            []
            [ text feedback.name ]
        ]
