module OrganizationDisplayTest exposing (..)

import Expect
import Test exposing (..)
import Test.Html.Query as Query
import Test.Html.Selector exposing (id, text, class, tag)
import Page.Organization.Display as OrganizationDisplay


suit : Test
suit =
    describe "Organization Display Module"
        [ test "renders view" <|
            \_ ->
                OrganizationDisplay.view OrganizationDisplay.initModel
                    |> Query.fromHtml
                    |> Query.has [ tag "div", tag "h1", id "content-wrapper" ]
        , test "renderArticle renders unordered list" <|
            \_ ->
                OrganizationDisplay.renderArticle { id = 1, title = "Example" }
                    |> Query.fromHtml
                    |> Query.has [ tag "ul", tag "li", text "Example" ]
        ]
