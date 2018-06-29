module CategoryCreateTest exposing (..)

import Page.Category.Create as CategoryCreate
import Expect
import Test exposing (..)
import Fuzz exposing (Fuzzer)
import Test.Html.Query as Query
import Test.Html.Selector exposing (id, text, class, tag)


suit : Test
suit =
    describe "Category Create module"
        [ test "Renders view with input and button" <|
            \_ ->
                CategoryCreate.view CategoryCreate.initModel
                    |> Query.fromHtml
                    |> Query.has [ tag "input", tag "button" ]
        , test "validateCategoryName checks for valid category name" <|
            \_ ->
                let
                    model =
                        CategoryCreate.initModel

                    updatedModel =
                        { model
                            | nameError = Just "Category name is required"
                        }
                in
                    CategoryCreate.validateCategoryName model
                        |> Expect.equal updatedModel
        , test "isValid returns true if any errors are not present" <|
            \_ ->
                CategoryCreate.isValid CategoryCreate.initModel
                    |> Expect.equal True
        , test "isValid returns False if any errors are present for model" <|
            \_ ->
                let
                    model =
                        CategoryCreate.validate CategoryCreate.initModel
                in
                    CategoryCreate.isValid model
                        |> Expect.equal False
        ]
