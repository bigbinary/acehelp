module Page.Article.Common exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Admin.Data.Category exposing (..)
import Admin.Data.Url exposing (..)
import Admin.Data.Common exposing (..)
import Page.Common.View exposing (..)


type Status
    = Saving
    | None


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
