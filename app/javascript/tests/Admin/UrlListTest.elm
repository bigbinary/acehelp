module UrlListTest exposing (..)

import Expect
import Test exposing (..)
import Test.Html.Query as Query
import Test.Html.Selector exposing (..)
import Page.Url.List as UrlList


suit : Test
suit =
    describe "Url List Module"
        [ test "renders view" <|
            \_ ->
                UrlList.view UrlList.initModel
                    |> Query.fromHtml
                    |> Query.has [ tag "div", class "buttonDiv", tag "a" ]
        , test "urlRow renders divs" <|
            \_ ->
                UrlList.urlRow { id = 1, url = "http://www.google.com" }
                    |> Query.fromHtml
                    |> Query.has [ tag "div" ]
        ]
