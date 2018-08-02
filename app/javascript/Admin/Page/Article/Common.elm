module Page.Article.Common exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Admin.Data.Category exposing (..)
import Admin.Data.Article exposing (..)
import Admin.Data.Url exposing (..)
import Field exposing (..)


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


articleInputs : { title : Field String String, desc : Field String String, categoryId : Field String String } -> CreateArticleInputs
articleInputs { title, desc, categoryId } =
    { title = Field.value title
    , desc = Field.value desc
    , categoryId = Just <| Field.value categoryId
    }
