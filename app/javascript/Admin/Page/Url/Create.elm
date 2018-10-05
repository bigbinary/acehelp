module Page.Url.Create exposing (Model, Msg(..), init, initModel, save, update, view)

import Admin.Data.ReaderCmd exposing (..)
import Admin.Data.Setting exposing (..)
import Admin.Data.Url exposing (..)
import Admin.Request.Setting exposing (..)
import Admin.Request.Url exposing (..)
import Field exposing (..)
import Field.ValidationResult as ValidationResult exposing (..)
import GraphQL.Client.Http as GQLClient
import Helpers exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Page.Url.Common exposing (..)
import Reader exposing (Reader)
import Request.Helpers exposing (ApiKey, NodeEnv)
import Route
import Task exposing (Task)



-- MODEL


type alias Model =
    { errors : List String
    , rule : Field String UrlRule
    }


initModel : Model
initModel =
    { errors = []
    , rule = Field validateSelectedRule (UrlIs "")
    }


init : ( Model, List (ReaderCmd Msg) )
init =
    ( initModel
    , []
    )



-- UPDATE


type Msg
    = UrlPatternInput String
    | SaveUrl
    | SaveUrlResponse (Result GQLClient.Error UrlResponse)
    | RuleChange String


update : Msg -> Model -> ( Model, List (ReaderCmd Msg) )
update msg model =
    case msg of
        UrlPatternInput path ->
            let
                newPath =
                    case ( String.startsWith "/" path, Field.value model.rule ) of
                        ( True, _ ) ->
                            path

                        ( False, UrlIs _ ) ->
                            path

                        ( False, _ ) ->
                            "/" ++ path
            in
            ( { model | rule = Field.update model.rule <| updateRuleValue newPath <| Field.value model.rule }, [] )

        SaveUrl ->
            case validate model.rule of
                Failed err ->
                    ( { model | errors = [ err ] }, [] )

                Passed _ ->
                    save model

        SaveUrlResponse (Ok id) ->
            -- NOTE: Redirection handled in Main
            ( model, [] )

        SaveUrlResponse (Err error) ->
            ( { model | errors = [ "An error occured while saving the Url" ] }, [] )

        RuleChange rule ->
            case rule of
                "is" ->
                    ( { model | rule = Field.update model.rule <| updateRuleType UrlIs <| Field.value model.rule }, [] )

                "contains" ->
                    ( { model | rule = Field.update model.rule <| updateRuleType UrlContains <| Field.value model.rule }, [] )

                "ends_with" ->
                    ( { model | rule = Field.update model.rule <| updateRuleType UrlEndsWith <| Field.value model.rule }, [] )

                _ ->
                    ( { model | errors = [ "Something went wrong. Please check the selected URL Rule" ] }, [] )



-- VIEW


view : Model -> Html Msg
view { errors, rule } =
    commonView
        { title = "Create a Url Pattern"
        , errors = errors
        , success = Nothing
        , rule = rule
        , onSaveUrl = SaveUrl
        , onUrlPatternInput = UrlPatternInput
        , onRuleChange = RuleChange
        , saveLabel = "Save"
        }


save : Model -> ( Model, List (ReaderCmd Msg) )
save model =
    let
        ( rule, pattern ) =
            ruleToString <| Field.value model.rule

        cmd =
            Strict <| Reader.map (Task.attempt SaveUrlResponse) (createUrl { url_rule = rule, url_pattern = pattern })
    in
    ( model, [ cmd ] )
