module Page.Article.Common exposing
    ( SaveStatus(..)
    , categoryToValue
    , errorsIn
    , multiSelectCategoryList
    , multiSelectUrlList
    , onTrixChange
    , savingIndicator
    , selectItemInList
    , selectItemsInList
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
import Html.Events exposing (on)
import Json.Decode as Json


type SaveStatus
    = Saving
    | None


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


multiSelectCategoryList : String -> List (Option Category) -> (Option CategoryId -> msg) -> Html msg
multiSelectCategoryList title categories onItemClick =
    multiSelectMenu title (List.map categoryToValue categories) onItemClick


savingIndicator : Html msg
savingIndicator =
    div [ class "save-indicator" ]
        [ text "Saving.." ]


multiSelectUrlList : String -> List (Option UrlData) -> (Option UrlId -> msg) -> Html msg
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


selectItemsInList : List (Option a) -> List (Option { b | id : a }) -> List (Option { b | id : a })
selectItemsInList selectedItems itemList =
    List.foldl
        (\selectedItem acc ->
            selectItemInList selectedItem acc
        )
        itemList
        selectedItems


selectItemInList : Option a -> List (Option { b | id : a }) -> List (Option { b | id : a })
selectItemInList selectedItem itemList =
    List.map
        (\item ->
            case ( item, selectedItem ) of
                ( Selected innerItem, Unselected newItemId ) ->
                    if innerItem.id == newItemId then
                        Unselected innerItem

                    else
                        Selected innerItem

                ( Unselected innerItem, Selected newItemId ) ->
                    if innerItem.id == newItemId then
                        Selected innerItem

                    else
                        Unselected innerItem

                _ ->
                    item
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


statusClass : AvailabilityStatus -> String
statusClass status =
    case status of
        Active ->
            "online-status"

        Inactive ->
            "offline-status"


statusToButtonText : AvailabilityStatus -> String
statusToButtonText status =
    case status of
        Inactive ->
            "Active"

        Active ->
            "Inactive"


onTrixChange : (String -> msg) -> Attribute msg
onTrixChange handler =
    Json.at [ "target", "value" ] Json.string
        |> Json.map handler
        |> on "trix-change"
