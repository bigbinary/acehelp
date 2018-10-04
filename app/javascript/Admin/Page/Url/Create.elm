module Page.Url.Create exposing (Model, Msg(..), init, initModel, save, update, view)

import Admin.Data.ReaderCmd exposing (..)
import Admin.Data.Setting exposing (..)
import Admin.Data.Url exposing (..)
import Admin.Request.Setting exposing (..)
import Admin.Request.Url exposing (..)
import Admin.Views.Common exposing (errorView)
import Field exposing (..)
import Field.ValidationResult as ValidationResult exposing (..)
import GraphQL.Client.Http as GQLClient
import Helpers exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
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


validateSelectedRule : UrlRule -> ValidationResult String UrlRule
validateSelectedRule rule =
    case rule of
        UrlIs url ->
            ValidationResult.map UrlIs <| validateUrl url

        UrlContains url ->
            ValidationResult.map UrlContains <| validateUrlRule url

        UrlEndsWith url ->
            ValidationResult.map UrlEndsWith <| validateUrlRule url


updateRuleType : (String -> UrlRule) -> UrlRule -> UrlRule
updateRuleType newType urlRule =
    case urlRule of
        UrlIs url ->
            newType url

        UrlContains url ->
            newType url

        UrlEndsWith url ->
            newType url


updateRuleValue : String -> UrlRule -> UrlRule
updateRuleValue newValue urlRule =
    case urlRule of
        UrlIs url ->
            UrlIs newValue

        UrlContains url ->
            UrlContains newValue

        UrlEndsWith url ->
            UrlEndsWith newValue


ruleTypeToString : Model -> String
ruleTypeToString model =
    Tuple.first <| ruleToString <| Field.value model.rule



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
                    case String.startsWith "/" path of
                        True ->
                            path

                        False ->
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
view model =
    div [ class "url-container row" ]
        [ Html.form [ onSubmit SaveUrl ]
            [ errorView model.errors
            , h4 [] [ text "Create a URL Pattern" ]
            , div []
                [ select [ onInput RuleChange ]
                    [ option [ selected ("is" == ruleTypeToString model), Html.Attributes.value "is" ] [ text "Url Is" ]
                    , option [ selected ("contains" == ruleTypeToString model), Html.Attributes.value "contains" ] [ text "Url Contains" ]
                    , option [ selected ("ends_with" == ruleTypeToString model), Html.Attributes.value "ends_with" ] [ text "Url Ends With" ]
                    ]
                , input
                    [ type_ "text"
                    , placeholder "Url..."
                    , onInput UrlPatternInput
                    , required True
                    , autofocus True
                    , id "url-input"
                    , Html.Attributes.value <| Tuple.second <| ruleToString <| Field.value model.rule
                    ]
                    []
                ]
            , button [ type_ "submit", class "btn btn-primary" ] [ text "Save URL" ]
            ]
        ]


save : Model -> ( Model, List (ReaderCmd Msg) )
save model =
    let
        ( rule, pattern ) =
            ruleToString <| Field.value model.rule

        cmd =
            Strict <| Reader.map (Task.attempt SaveUrlResponse) (createUrl { url_rule = rule, url_pattern = pattern })
    in
    ( model, [ cmd ] )
