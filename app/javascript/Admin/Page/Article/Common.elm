module Page.Article.Common exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Admin.Data.Category exposing (..)
import Admin.Data.Article exposing (..)
import Admin.Data.Url exposing (..)
import Json.Decode as Json
import Json.Decode.Extra as JsonEx
import Field exposing (..)


type Status
    = Saving
    | None


type ArticleUrl
    = Selected UrlData
    | Unselected UrlData


errorView : Maybe String -> Html msg
errorView error =
    Maybe.withDefault (text "") <|
        Maybe.map
            (\err ->
                div [ class "alert alert-danger alert-dismissible fade show", attribute "role" "alert" ]
                    [ text <| "Error: " ++ err
                    ]
            )
            error


articleUrls : List UrlData -> Html msg
articleUrls urls =
    div []
        [ h6 [] [ text "Linked URLs:" ]
        , span [ class "badge badge-secondary" ] [ text "/getting-started/this-is-hardcoded" ]
        ]


categoryListDropdown : List Category -> CategoryId -> (CategoryId -> msg) -> Html msg
categoryListDropdown categories selectedId onItemClick =
    let
        selectedCategory =
            List.filter (\category -> category.id == selectedId) categories
                |> List.map .name
                |> List.head
                |> Maybe.withDefault "Select Category"
    in
        div []
            [ div [ class "dropdown" ]
                [ a
                    [ class "btn btn-secondary dropdown-toggle"
                    , attribute "role" "button"
                    , attribute "data-toggle" "dropdown"
                    , attribute "aria-haspopup" "true"
                    , attribute "aria-expanded" "false"
                    ]
                    [ text selectedCategory ]
                , div
                    [ class "dropdown-menu", attribute "aria-labelledby" "dropdownMenuButton" ]
                    (List.map
                        (\category ->
                            a [ class "dropdown-item", onClick (onItemClick category.id) ] [ text category.name ]
                        )
                        categories
                    )
                ]
            ]


savingIndicator : Html msg
savingIndicator =
    div [ class "save-indicator" ]
        [ text "Saving.." ]


targetSelectedOptions : Json.Decoder (List String)
targetSelectedOptions =
    Json.at [ "target", "selectedOptions" ] <|
        JsonEx.collection <|
            Json.at [ "value" ] <|
                Json.string


multiSelectUrlList : String -> List ArticleUrl -> (List String -> msg) -> Html msg
multiSelectUrlList title urls onselect =
    div []
        [ h6 [] [ text title ]
        , select [ on "change" (Json.map onselect targetSelectedOptions), multiple True, class "form-control select-checkbox", size 5 ] <|
            List.map
                (\url ->
                    case url of
                        Selected urlItem ->
                            option [ Html.Attributes.value urlItem.id, selected True ] [ text urlItem.url ]

                        Unselected urlItem ->
                            option [ Html.Attributes.value urlItem.id, selected False ] [ text urlItem.url ]
                )
                urls
        ]
