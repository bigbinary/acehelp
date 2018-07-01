module ArticleCreateTest exposing (..)

import Page.Article.Create as ArticleCreate
import Expect
import Test exposing (..)
import Fuzz exposing (Fuzzer)
import Test.Html.Query as Query
import Test.Html.Selector exposing (id, text, class, tag)


suite : Test
suite =
    describe "Article Create Module"
        [ test "Renders form for article creation" <|
            \_ ->
                ArticleCreate.view ArticleCreate.initModel
                    |> Query.fromHtml
                    |> Query.has [ tag "input", tag "select", tag "button" ]
        , test "Renders dropdown for category selection" <|
            \_ ->
                ArticleCreate.categoryListDropdown ArticleCreate.initModel
                    |> Query.fromHtml
                    |> Query.has [ tag "select", tag "option" ]
        , test "when title is empty title error is present" <|
            \_ ->
                let
                    model =
                        ArticleCreate.initModel

                    updatedModel =
                        { model | titleError = Just "Title should be present" }
                in
                    ArticleCreate.validateTitle model
                        |> Expect.equal updatedModel
        , test "whenever desc is empty description error will be present" <|
            \_ ->
                let
                    model =
                        ArticleCreate.initModel

                    updatedModel =
                        { model | descError = Just "Desc is required" }
                in
                    ArticleCreate.validateDesc model
                        |> Expect.equal updatedModel
        , test "whenever keyword is empty error is raised" <|
            \_ ->
                let
                    model =
                        ArticleCreate.initModel

                    updatedModel =
                        { model | keywordError = Just "Keyword is required" }
                in
                    ArticleCreate.validateKeyword model
                        |> Expect.equal updatedModel
        , test "whenever category ID is is not selected error is raised" <|
            \_ ->
                let
                    model =
                        ArticleCreate.initModel

                    updatedModel =
                        { model | categoryIdError = Just "Please select category" }
                in
                    ArticleCreate.validateCategoryId model
                        |> Expect.equal updatedModel
        , test "isValid returns true if errors are not present" <|
            \_ ->
                let
                    model =
                        ArticleCreate.initModel
                in
                    ArticleCreate.isValid model
                        |> Expect.equal True
        , test "isValid returns false if errors are present" <|
            \_ ->
                let
                    model =
                        ArticleCreate.initModel

                    updatedModel =
                        { model | titleError = Just "Title should be present" }
                in
                    ArticleCreate.isValid updatedModel
                        |> Expect.equal False
        ]
