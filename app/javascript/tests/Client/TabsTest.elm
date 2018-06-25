module TabsTest exposing (..)

import Views.Tabs as Tabs
import Expect
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import Test.Html.Query as Query
import Test.Html.Selector exposing (id, text, class)
import List.Zipper as Zipper exposing (Zipper)


suite : Test
suite =
    -- todo "Implement our first test. See http://package.elm-lang.org/packages/elm-community/elm-test/latest for how to do this!"
    describe "Tabs Module"
        [ test "Render tabs from list" <|
            \_ ->
                Tabs.view (Tabs.modelWithTabs [ Tabs.SuggestedArticles, Tabs.Library, Tabs.ContactUs ])
                    |> Query.fromHtml
                    |> Query.findAll [ class "tabs" ]
                    |> Query.count (Expect.equal 3)
        , test "Init" <|
            \_ ->
                Tabs.init
                    |> Expect.equal ( Zipper.singleton Tabs.ContactUs, Cmd.none )
        , test "If no tabs are provided to modelWithTabs. It defaults to Contact Us tab" <|
            \_ ->
                Tabs.modelWithTabs []
                    |> Expect.equal (Zipper.singleton Tabs.ContactUs)
        , test "allTabs returns a list of all available Tabs" <|
            \_ ->
                Tabs.allTabs
                    |> Expect.equalLists [ Tabs.SuggestedArticles, Tabs.Library, Tabs.ContactUs ]
        ]
