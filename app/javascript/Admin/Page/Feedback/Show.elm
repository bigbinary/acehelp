module Page.Feedback.Show exposing (..)

import Html exposing (..)
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
    , error : Maybe String
    }


initModel : FeedbackId -> Model
initModel feedbackId =
    { name = ""
    , message = ""
    , error = Nothing
    }


init : FeedbackId -> ( Model, Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error Feedback) )
init feedbackId =
    ( initModel feedbackId
    , requestFeedbackById feedbackId
    )



-- Update


type Msg
    = FeedbackLoaded (Result GQLClient.Error Feedback)



-- TODO: Fetch categories to populate categories dropdown


update : Msg -> Model -> NodeEnv -> ApiKey -> ( Model, Cmd Msg )
update msg model nodeEnv organizationKey =
    case msg of
        FeedbackLoaded (Ok feedback) ->
            ( { model
                | name = feedback.name
                , message = feedback.message
              }
            , Cmd.none
            )

        FeedbackLoaded (Err err) ->
            ( { model | error = Just "There was an error loading up the feedback" }
            , Cmd.none
            )



-- View


view : Model -> Html Msg
view model =
    div []
        []
