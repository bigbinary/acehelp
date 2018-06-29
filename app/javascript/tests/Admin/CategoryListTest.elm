module CategoryListTest exposing (..)

import Expect
import Test exposing (..)
import Test.Html.Query as Query
import Test.Html.Selector exposing (id, text, class, tag)
import Page.Category.List as CategoryList


suit : Test
suit =
    describe "Category List Module"
        [ test "renders view" <|
            \_ ->
                CategoryList.view CategoryList.initModel
                    |> Query.fromHtml
                    |> Query.has [ tag "div", tag "a", class "buttonDiv" ]
        , test "categoryRow render divs" <|
            \_ ->
                CategoryList.categoryRow { id = 1, name = "Getting Started" }
                    |> Query.fromHtml
                    |> Query.has [ tag "div" ]
        ]
