module UrlCreateTest exposing (..)

import Expect
import Test exposing (..)
import Test.Html.Query as Query
import Test.Html.Selector exposing (id, tag, class, text)
import Page.Url.Create as UrlCreate


suit : Test
suit =
    describe "Url Create Module"
        [ test "renders view" <|
            \_ ->
                UrlCreate.view UrlCreate.initModel
                    |> Query.fromHtml
                    |> Query.has [ tag "div", tag "button", tag "input", tag "label", class "container", text "URL: ", text "URL Title: " ]
        , test "validateUrl validates presence of url in model" <|
            \_ ->
                let
                    model =
                        UrlCreate.initModel

                    updatedModel =
                        { model
                            | urlError = Just "Url is required"
                        }
                in
                    UrlCreate.validateUrl model
                        |> Expect.equal updatedModel
        , test "validateUrlTitle validates presence of url title" <|
            \_ ->
                let
                    model =
                        UrlCreate.initModel

                    updatedModel =
                        { model
                            | urlTitleError = Just "Title required"
                        }
                in
                    UrlCreate.validateUrlTitle model
                        |> Expect.equal updatedModel
        , test "isValid returns true if no errors are there for model" <|
            \_ ->
                UrlCreate.isValid UrlCreate.initModel
                    |> Expect.equal True
        , test "isValid returns false if errors are present for a model" <|
            \_ ->
                let
                    model =
                        UrlCreate.validate UrlCreate.initModel
                in
                    UrlCreate.isValid model
                        |> Expect.equal False
        ]
