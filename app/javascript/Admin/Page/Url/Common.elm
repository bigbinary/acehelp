module Page.Url.Common exposing
    ( commonView
    , ruleToClass
    , ruleTypeToString
    , updateRuleType
    , updateRuleValue
    , validateSelectedRule
    )

import Admin.Data.ReaderCmd exposing (..)
import Admin.Data.Setting exposing (..)
import Admin.Data.Url exposing (..)
import Admin.Request.Setting exposing (..)
import Admin.Request.Url exposing (..)
import Admin.Views.Common exposing (errorView, successView)
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


ruleTypeToString : Field String UrlRule -> String
ruleTypeToString rule =
    Tuple.first <| ruleToString <| Field.value rule


commonView :
    { title : String
    , errors : List String
    , rule : Field String UrlRule
    , success : Maybe String
    , onSaveUrl : msg
    , onRuleChange : String -> msg
    , onUrlPatternInput : String -> msg
    , saveLabel : String
    }
    -> Html msg
commonView { title, errors, rule, success, onSaveUrl, onRuleChange, onUrlPatternInput, saveLabel } =
    div [ class "url-container" ]
        [ Html.form [ onSubmit onSaveUrl ]
            [ errorView errors
            , successView success
            , h4 [] [ text title ]
            , div [ class "form-group" ]
                [ label [ for "rule-type" ] [ text "Pattern Type: " ]
                , select [ id "rule-type", class "form-control", onInput onRuleChange ]
                    [ option [ selected ("is" == ruleTypeToString rule), Html.Attributes.value "is" ] [ text "Url Is" ]
                    , option [ selected ("contains" == ruleTypeToString rule), Html.Attributes.value "contains" ] [ text "Url Contains" ]
                    , option [ selected ("ends_with" == ruleTypeToString rule), Html.Attributes.value "ends_with" ] [ text "Url Ends With" ]
                    ]
                ]
            , div [ class "form-group" ]
                [ label [ for "url-input" ] []
                , input
                    [ type_ "text"
                    , placeholder "Please enter a URL Pattern. \"*\" can be used as a wildcard"
                    , onInput onUrlPatternInput
                    , required True
                    , autofocus True
                    , id "url-input"
                    , Html.Attributes.value <| Tuple.second <| ruleToString <| Field.value rule
                    ]
                    []
                ]
            , button [ type_ "submit", class "btn btn-primary" ] [ text saveLabel ]
            ]
        ]


ruleToClass rule =
    case rule of
        UrlIs _ ->
            "url-is"

        UrlContains _ ->
            "url-contains"

        UrlEndsWith _ ->
            "url-ends-with"
