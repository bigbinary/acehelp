module Page.Article.Common exposing
    ( SaveSatus(..)
    , articleUrls
    , categoryToValue
    , errorView
    , errorsIn
    , itemSelection
    , multiSelectCategoryList
    , multiSelectUrlList
    , savingIndicator
    , statusClass
    , statusToButtonText
    , successView
    , urlToValue
    )

import Admin.Data.Category exposing (..)
import Admin.Data.Common exposing (..)
import Admin.Data.Status exposing (..)
import Admin.Data.Url exposing (..)
import Admin.Views.Common exposing (..)
import Field exposing (..)
import Field.ValidationResult exposing (..)
import Helpers exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)


type SaveSatus
    = Saving
    | None


errorView : List String -> Html msg
errorView errors =
    case errors of
        [] ->
            text ""

        _ ->
            div [ class "alert alert-danger alert-dismissible fade show", attribute "role" "alert" ]
                [ text <| (++) "Error: " <| String.join ", " errors ]


successView : Maybe String -> Html msg
successView success =
    Maybe.withDefault (text "") <|
        Maybe.map
            (\message ->
                div [ class "alert alert-success alert-dismissible fade show", attribute "role" "alert" ]
                    [ text <| message
                    ]
            )
            success


articleUrls : List UrlData -> Html msg
articleUrls urls =
    div []
        [ h6 [] [ text "Linked URLs:" ]
        , span [ class "badge badge-secondary" ] [ text "/getting-started/this-is-hardcoded" ]
        ]


multiSelectCategoryList : String -> List (Option Category) -> (List CategoryId -> msg) -> Html msg
multiSelectCategoryList title categories onItemClick =
    multiSelectMenu title (List.map categoryToValue categories) onItemClick


savingIndicator : Html msg
savingIndicator =
    div [ class "save-indicator" ]
        [ text "Saving.." ]


multiSelectUrlList : String -> List (Option UrlData) -> (List UrlId -> msg) -> Html msg
multiSelectUrlList title urls onselect =
    multiSelectMenu title (List.map urlToValue urls) onselect


categoryToValue : Option Category -> Option Value
categoryToValue category =
    case category of
        Selected item ->
            Selected
                { id = item.id
                , value = item.name
                }

        Unselected item ->
            Unselected
                { id = item.id
                , value = item.name
                }


urlToValue : Option UrlData -> Option Value
urlToValue url =
    case url of
        Selected item ->
            Selected
                { id = item.id
                , value = item.url
                }

        Unselected item ->
            Unselected
                { id = item.id
                , value = item.url
                }


itemSelection : List a -> List (Option { b | id : a }) -> List (Option { b | id : a })
itemSelection selectedItemList itemList =
    let
        switchItem item =
            if List.member item.id selectedItemList then
                Selected item

            else
                Unselected item
    in
    List.map
        (\item ->
            case item of
                Selected innerItem ->
                    switchItem innerItem

                Unselected innerItem ->
                    switchItem innerItem
        )
        itemList


errorsIn : List (Field String v) -> List String
errorsIn fields =
    validateAll fields
        |> filterFailures
        |> List.map
            (\result ->
                case result of
                    Failed err ->
                        err

                    Passed _ ->
                        "Unknown Error"
            )


statusClass : AvailabilitySatus -> String
statusClass status =
    case status of
        Active ->
            "online-status"

        Inactive ->
            "offline-status"


statusToButtonText : AvailabilitySatus -> String
statusToButtonText status =
    case status of
        Inactive ->
            "Active"

        Active ->
            "Inactive"
