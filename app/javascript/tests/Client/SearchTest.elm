module SearchTest exposing (..)

import Section.Search as Search
import Test exposing (..)
import Test.Html.Query as Query
import Test.Html.Selector exposing (id, text, class, tag)


suite : Test
suite =
    describe "Search Module"
        [ test "Renders a search bar with one input text" <|
            \_ ->
                Search.view "" "rgb(60, 170, 249)"
                    |> Query.fromHtml
                    |> Query.has [ tag "input", tag "span" ]
        ]
