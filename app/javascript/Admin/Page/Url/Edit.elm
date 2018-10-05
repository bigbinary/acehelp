module Page.Url.Edit exposing (Model, Msg(..), init, initModel, save, update, urlInputs, view)

import Admin.Data.ReaderCmd exposing (..)
import Admin.Data.Setting exposing (..)
import Admin.Data.Url exposing (..)
import Admin.Request.Setting exposing (..)
import Admin.Request.Url exposing (..)
import Admin.Views.Common exposing (errorView)
import Field exposing (..)
import Field.ValidationResult exposing (..)
import GraphQL.Client.Http as GQLClient
import Helpers exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Page.Url.Common exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)



-- MODEL


type alias Model =
    { errors : List String
    , success : Maybe String
    , urlId : UrlId
    , rule : Field String UrlRule
    }


initModel : UrlId -> Model
initModel urlId =
    { errors = []
    , success = Nothing
    , rule = Field validateSelectedRule (UrlIs "")
    , urlId = urlId
    }


init : UrlId -> ( Model, List (ReaderCmd Msg) )
init urlId =
    ( initModel urlId
    , [ Strict <| Reader.map (Task.attempt UrlLoaded) (requestUrlById urlId)
      ]
    )



-- UPDATE


type Msg
    = RuleChange String
    | UpdateUrl
    | UpdateUrlResponse (Result GQLClient.Error UrlResponse)
    | UrlLoaded (Result GQLClient.Error (Maybe UrlData))
    | UrlPatternInput String


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

        UpdateUrl ->
            case validate model.rule of
                Failed err ->
                    ( { model | errors = [ err ] }, [] )

                Passed _ ->
                    save model

        UpdateUrlResponse (Ok id) ->
            ( model, [] )

        UpdateUrlResponse (Err error) ->
            ( { model | errors = [ "An error occured while updating the Url information" ] }, [] )

        UrlLoaded (Ok url) ->
            case url of
                Just { id, url_rule, url_pattern } ->
                    ( { model
                        | urlId = id
                        , rule = Field.update model.rule <| Maybe.withDefault (UrlIs "") <| stringToRule ( url_rule, url_pattern )
                      }
                    , []
                    )

                Nothing ->
                    ( { model | errors = [ "There was an error while loading the url" ] }, [] )

        UrlLoaded (Err err) ->
            ( { model | errors = [ "There was an error while loading the url" ] }, [] )

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
        { title = "Edit Url Pattern"
        , errors = errors
        , success = Nothing
        , rule = rule
        , onSaveUrl = UpdateUrl
        , onUrlPatternInput = UrlPatternInput
        , onRuleChange = RuleChange
        , saveLabel = "Update Url"
        }


urlInputs : Model -> UrlData
urlInputs { urlId, rule } =
    let
        ( urlRule, pattern ) =
            ruleToString <| Field.value rule
    in
    { id = urlId
    , url_rule = urlRule
    , url_pattern = pattern
    }


save : Model -> ( Model, List (ReaderCmd Msg) )
save model =
    let
        cmd =
            Strict <| Reader.map (Task.attempt UpdateUrlResponse) (updateUrl <| urlInputs model)
    in
    ( model, [ cmd ] )
