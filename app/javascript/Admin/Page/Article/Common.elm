module Page.Article.Common exposing
    ( SaveStatus(..)
    , categoryToValue
    , editorId
    , errorsIn
    , multiSelectCategoryList
    , multiSelectUrlList
    , onTrixChange
    , pendingActionsOnDescriptionChange
    , preventSaveForPendingActions
    , proposedEditorHeightPayload
    , savingIndicator
    , selectItemInList
    , selectItemsInList
    , statusClass
    , statusToButtonText
    , trixEditorToolbarView
    , unsavedArticlePendingActionId
    , urlToValue
    )

import Admin.Data.Article exposing (Article)
import Admin.Data.Category exposing (..)
import Admin.Data.Common exposing (..)
import Admin.Data.Status exposing (..)
import Admin.Data.Url exposing (..)
import Admin.Views.Common exposing (..)
import Browser.Dom as Dom
import Field exposing (..)
import Field.ValidationResult exposing (..)
import Helpers exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onClick)
import Json.Decode as Json
import PendingActions exposing (PendingActions)


type SaveStatus
    = Saving
    | None


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


editorId : String
editorId =
    "article-editor"



-- isEditorContentsSaved :


proposedEditorHeightPayload : Dom.Element -> { editorId : String, height : Float }
proposedEditorHeightPayload { viewport, element } =
    let
        bottomSpacing =
            10.0

        proposedHeight =
            viewport.height - element.y - bottomSpacing

        payload =
            { editorId = editorId, height = proposedHeight }
    in
    payload


trixEditorToolbarView : msg -> Html msg
trixEditorToolbarView addAttachmentsMsg =
    node "trix-toolbar"
        [ id "trix-custom-toolbar" ]
        [ div [ class "trix-button-row" ]
            [ span
                [ class "trix-button-group trix-button-group--text-tools"
                , attribute "data-trix-button-group" "text-tools"
                ]
                [ button
                    [ type_ "button"
                    , class "trix-button trix-button--icon trix-button--icon-bold"
                    , attribute "data-trix-attribute" "bold"
                    , attribute "data-trix-key" "b"
                    , title "bold"
                    , tabindex -1
                    ]
                    [ text "Bold" ]
                , button
                    [ type_ "button"
                    , class "trix-button trix-button--icon trix-button--icon-italic"
                    , attribute "data-trix-attribute" "italic"
                    , attribute "data-trix-key" "i"
                    , title "Italic"
                    , tabindex -1
                    ]
                    [ text "Italic" ]
                , button
                    [ type_ "button"
                    , class "trix-button trix-button--icon trix-button--icon-strike"
                    , attribute "data-trix-attribute" "strike"
                    , title "Strikethrough"
                    , tabindex -1
                    ]
                    [ text "Strikethrough" ]
                , button
                    [ type_ "button"
                    , class "trix-button trix-button--icon trix-button--icon-link"
                    , attribute "data-trix-attribute" "href"
                    , attribute "data-trix-action" "link"
                    , attribute "data-trix-key" "k"
                    , title "Link"
                    , tabindex -1
                    ]
                    [ text "Link" ]
                ]
            , span
                [ class "trix-button-group trix-button-group--block-tools"
                , attribute "data-trix-button-group" "block-tools"
                ]
                [ button
                    [ type_ "button"
                    , class "trix-button trix-button--icon trix-button--icon-heading-1"
                    , attribute "data-trix-attribute" "heading1"
                    , title "Heading"
                    , tabindex -1
                    ]
                    [ text "Heading" ]
                , button
                    [ type_ "button"
                    , class "trix-button trix-button--icon trix-button--icon-quote"
                    , attribute "data-trix-attribute" "quote"
                    , title "Quote"
                    , tabindex -1
                    ]
                    [ text "Quote" ]
                , button
                    [ type_ "button"
                    , class "trix-button trix-button--icon trix-button--icon-code"
                    , attribute "data-trix-attribute" "code"
                    , title "Code"
                    , tabindex -1
                    ]
                    [ text "Code" ]
                , button
                    [ type_ "button"
                    , class "trix-button trix-button--icon trix-button--icon-bullet-list"
                    , attribute "data-trix-attribute" "bullet"
                    , title "Bullets"
                    , tabindex -1
                    ]
                    [ text "Bullets" ]
                , button
                    [ type_ "button"
                    , class "trix-button trix-button--icon trix-button--icon-number-list"
                    , attribute "data-trix-attribute" "number"
                    , title "Numbers"
                    , tabindex -1
                    ]
                    [ text "Numbers" ]
                , button
                    [ type_ "button"
                    , class "trix-button trix-button--icon trix-button--icon-decrease-nesting-level"
                    , attribute "data-trix-action" "decreaseNestingLevel"
                    , title "Decrease Level"
                    , tabindex -1
                    ]
                    [ text "Decrease Level" ]
                , button
                    [ type_ "button"
                    , class "trix-button trix-button--icon trix-button--icon-increase-nesting-level"
                    , attribute "data-trix-action" "increaseNestingLevel"
                    , title "Increase Level"
                    , tabindex -1
                    ]
                    [ text "Increase Level" ]
                ]
            , span
                [ class "trix-button-group trix-button-group--block-tools", attribute "data-trix-button-group" "block-tools" ]
                [ button
                    [ type_ "button"
                    , class "trix-button trix-button--icon trix-button--icon-attach"
                    , attribute "data-trix-action" "x-attach"
                    , title "Attach Files"
                    , tabindex -1
                    , onClick addAttachmentsMsg
                    ]
                    [ text "Attach Files" ]
                ]
            , span
                [ class "trix-button-group trix-button-group--history-tools", attribute "data-trix-button-group" "history-tools" ]
                [ button
                    [ type_ "button"
                    , class "trix-button trix-button--icon trix-button--icon-undo"
                    , attribute "data-trix-action" "undo"
                    , attribute "data-trix-key" "z"
                    , title "Undo"
                    , tabindex -1
                    ]
                    [ text "Undo" ]
                , button
                    [ type_ "button"
                    , class "trix-button trix-button--icon trix-button--icon-redo"
                    , attribute "data-trix-action" "redo"
                    , attribute "data-trix-key" "shift+z"
                    , title "Redo"
                    , tabindex -1
                    ]
                    [ text "Redo" ]
                ]
            ]
        ]


pendingActionsOnDescriptionChange :
    PendingActions
    -> Maybe Article
    -> String
    -> PendingActions
pendingActionsOnDescriptionChange pendingActions originalArticle newDescription =
    case originalArticle of
        Just article ->
            let
                pendingActionId =
                    unsavedArticlePendingActionId originalArticle

                message =
                    "Editor has unsaved contents."
            in
            if isDescriptionChanged article newDescription then
                PendingActions.add pendingActionId message pendingActions

            else
                PendingActions.remove pendingActionId pendingActions

        Nothing ->
            pendingActions


unsavedArticlePendingActionId : Maybe Article -> String
unsavedArticlePendingActionId originalArticle =
    case originalArticle of
        Just article ->
            "article-" ++ article.id

        Nothing ->
            "article"


isDescriptionChanged : Article -> String -> Bool
isDescriptionChanged article newDescription =
    articleDescription article /= newDescription


articleDescription : Article -> String
articleDescription article =
    if article.desc == "desc" then
        ""

    else
        article.desc


preventSaveForPendingActions : PendingActions -> Maybe Article -> Bool
preventSaveForPendingActions pendingActions originalArticle =
    let
        pendingId =
            unsavedArticlePendingActionId originalArticle

        unrelatedPendingActions =
            PendingActions.without pendingId pendingActions
    in
    unrelatedPendingActions |> PendingActions.isEmpty |> not
