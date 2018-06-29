module ArticleListTest exposing (..)

import Expect
import Test exposing (..)
import Test.Html.Query as Query
import Test.Html.Selector exposing (id, text, class, tag)
import Page.Article.List as ArticleList
import Data.ArticleData exposing (..)


suit : Test
suit =
    describe "Article List Module"
        [ test "Renders view" <|
            \_ ->
                ArticleList.view ArticleList.initModel
                    |> Query.fromHtml
                    |> Query.has [ tag "div", tag "select", tag "option" ]
        , test "Category row renders html" <|
            \_ ->
                ArticleList.rows { id = 1, title = "Getting Started", desc = "Desc" }
                    |> Query.fromHtml
                    |> Query.has [ tag "div" ]
        , test "urlsDropdown renders dropdown with select and options tag" <|
            \_ ->
                ArticleList.urlsDropdown ArticleList.initModel
                    |> Query.fromHtml
                    |> Query.has [ tag "select", tag "option", tag "div" ]
        ]
